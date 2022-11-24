{config, pkgs, lib,...}:
let

  laptop_layout = pkgs.writeScriptBin "screen_laptop_layout" ''
    #!${pkgs.stdenv.shell}
    xrandr --output HDMI-2 --off --output HDMI-1 --off --output DP-1 --off --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-2 --off
  '';

  homeoffice_layout = pkgs.writeScriptBin "screen_homeoffice_layout" ''
    #!${pkgs.stdenv.shell}
    xrandr --output eDP-1 --mode 1920x1080 --pos 320x1440 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --off --output HDMI-2 --primary --mode 2560x1440 --pos 0x0 --rotate normal
  '';

  office_layout = pkgs.writeScriptBin "screen_office_layout" ''
    #!${pkgs.stdenv.shell}
    xrandr --output HDMI-2 --mode 2560x1440 --pos 1920x0 --rotate left --output HDMI-1 --mode 1920x1200 --pos 0x1360 --rotate normal --output DP-1 --off --output eDP-1 --primary --mode 1920x1080 --pos 1680x2560 --rotate normal --output DP-2 --off
  '';

  coronaoffice_layout = pkgs.writeScriptBin "screen_coronaoffice_layout" ''
    #!${pkgs.stdenv.shell}
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x1200 --rotate normal --output DP-1 --off --output HDMI-1 --mode 1920x1200 --pos 0x0 --rotate normal --output DP-2 --off --output HDMI-2 --off
  '';

  mongo_connect = pkgs.writeScriptBin "mongoConnect" ''
    #!${pkgs.stdenv.shell}
    docker run --net="host" -it --entrypoint mongo mongo:3.2.10 --authenticationDatabase admin -u admin -p
  '';

  battery_notify = pkgs.writeScriptBin "batteryNotify" ''
    #!/usr/bin/env fish

    set -g battery_average (acpi | sed 's/^Battery.* \([0-9]\{1,3\}\)%.*$/\1/' | awk '{sum+= $1} END {print sum/ NR}')

    if [ "$battery_average" -lt 10 ]
      dunstify "ok. This is quite low now." $battery_average -u 2 -t 5000
      touch ~/.battery_low
    else if [ "$battery_average" -lt 5 ]
      if not test -e ~/.battery_low
        dunstify "allright partner. We are a bit low." $battery_average -t 0
      end
      touch ~/.battery_low
    else
      rm -f ~/.battery_low
    end

  '';

  vpn_office = pkgs.writeScriptBin "vpn-office" ''
    #!${pkgs.stdenv.shell}
    systemctl $1 openvpn-office.service
  '';

  vpn_private = pkgs.writeScriptBin "vpn-private" ''
    #!${pkgs.stdenv.shell}
    systemctl $1 openvpn-private.service
  '';

  theme = pkgs.writeScriptBin "theme" ''
    #!${pkgs.stdenv.shell}
    if grep -q "light" ~/.theme; then
        # kitty @set-colors --all --configured ~/.config/kitty/solarized-light.conf
        hsetroot -solid '#fdf6e3'
    else
        # kitty @set-colors --all --configured ~/.config/kitty/solarized-dark.conf
        hsetroot -solid '#002b36'
    fi
  '';

  dark_theme = pkgs.writeScriptBin "dark_theme" ''
    #!${pkgs.stdenv.shell}
    echo "dark" > ~/.theme
    theme
  '';

  light_theme = pkgs.writeScriptBin "light_theme" ''
    #!${pkgs.stdenv.shell}
    echo "light" > ~/.theme
    theme
  '';

  diary = pkgs.writeScriptBin "diary" ''
    #!${pkgs.stdenv.shell}

    if [ $# -eq 0 ]
      then
        DAYS=0
      else
        [[ $1 == "yesterday" || $1 == "y" ]] && DAYS=-1 || DAYS=$1
    fi

    DATE=" $DAYS day"
    MONTH_PATH=$(date --date="$DATE" +"%Y/%m" )
    DAY_PATH=$MONTH_PATH/$(date --date="$DATE" +"%d" )

    cd ~/.gitsync/plaintext/notes/diary

    mkdir -p $MONTH_PATH
    vim +Goyo $DAY_PATH.md -c ":set linebreak | let g:bufferline_fname_mod=':.'"
  '';

  cut_gif = pkgs.writeScriptBin "cut_gif" ''
    #!${pkgs.stdenv.shell}

    ffmpeg -i "$1" -vf select="between(n\,$2\,$3),setpts=PTS-STARTPTS" $4
  '';

  oc_rsh = pkgs.writeScriptBin "oc_rsh" ''
    #!${pkgs.stdenv.shell}
    oc project > /dev/tty && oc rsh $(oc get pods | fzf | cut -d " " -f1)
  '';

  oc_port_forward = pkgs.writeScriptBin "oc_port_forward" ''
    #!${pkgs.stdenv.shell}
    oc project > /dev/tty && echo "oc port-forward" $(oc get pods | fzf | cut -d ' ' -f1) $(echo -e '8080:8080 REST\n27017:27017 MongoDB\n8081:8080 REST alt1\n8082:8080 REST alt2\n8083:8080 REST alt3' | fzf --print-query | tail -n -1 | cut -d ' ' -f1) | tee /dev/tty | sh
  '';

  check_vehicle = pkgs.writeScriptBin "check_vehicle" ''
    #!${pkgs.stdenv.shell}

    CARHUB_ENV=$1
    VEHICLE_ID=$2

    PWD=$(pass show work/carhub/$CARHUB_ENV/admin | head -n 1)

    curl -v --user "admin:$PWD" -H "Content-Type: application/json" "https://carhub-$CARHUB_ENV.int.ocp.porscheinformatik.cloud/api/v1/vehicles/$VEHICLE_ID" | jq 
  '';

  check_vehicle_history = pkgs.writeScriptBin "check_vehicle_history" ''
    #!${pkgs.stdenv.shell}

    CARHUB_ENV=$1
    VEHICLE_ID=$2

    PWD=$(pass show work/carhub/$CARHUB_ENV/admin | head -n 1)

    curl -v --user "admin:$PWD" -H "Content-Type: application/json" "https://carhub-$CARHUB_ENV.int.ocp.porscheinformatik.cloud/api/v1/vehicles/$VEHICLE_ID/history" | jq 
  '';

  wallabag_add = pkgs.writeScriptBin "wallabag_add" ''
    #!${pkgs.stdenv.shell}

    URL=$1

    CONFIG=~/.wallabag

    SEARCH_CMD="jq -e -r "

    HOST=$(jq -r '.url' $CONFIG)
    USR=$(jq -r ".usr" $CONFIG)
    PWD=$(jq -r ".pwd" $CONFIG)
    CLIENT_ID=$(jq -r ".client_id" $CONFIG)
    CLIENT_SECRET=$(jq -r ".client_secret" $CONFIG)

    RESPONSE=$(http POST $HOST/oauth/v2/token \
      grant_type=password \
      client_id=$CLIENT_ID \
      client_secret=$CLIENT_SECRET \
      username=$USR \
      password=$PWD )

    TOKEN=$(echo $RESPONSE | jq -r ".access_token")

    http POST $HOST/api/entries.json \
      "Authorization:Bearer $TOKEN" \
      url="$URL"

  '';

in
{

  imports = [
    <home-manager/nixos>
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.agl = {
    isNormalUser = true;
    extraGroups = [ "wheel" # Enable ‘sudo’ for the user.
                    "docker" 
                    "networkmanager" 
                    "adbusers"
                  ]; 
    shell = pkgs.fish;
  };

  home-manager.users.agl = {pkgs, lib, ... }: {

    xsession = {
      enable = true;

      profileExtra = "
      hsetroot -solid '#002b36' &
      sleep 1 &&
      setxkbmap de &";

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        config = ./dotfiles/xmonad.hs;
      };
    };

    home.sessionVariables = {
      EDITOR = "vim";
      BROWSER = "qutebrowser";
    };

    home.packages = [ 
      laptop_layout 
      homeoffice_layout
      office_layout
      coronaoffice_layout
      mongo_connect
      vpn_office
      vpn_private
      theme
      light_theme
      dark_theme
      diary
      oc_rsh
      oc_port_forward
      check_vehicle
      check_vehicle_history
      cut_gif
      wallabag_add
      battery_notify
      ];

    home.file.".config/kitty/solarized-dark.conf".text = ''
      background              #002b36
      foreground              #839496
      cursor                  #93a1a1
      selection_background    #81908f
      selection_foreground    #002831 
      color0                  #073642
      color1                  #dc322f
      color10                 #586e75
      color11                 #657b83
      color12                 #839496
      color13                 #6c71c4
      color14                 #93a1a1
      color15                 #fdf6e3
      color2                  #859900
      color3                  #b58900
      color4                  #268bd2
      color5                  #d33682
      color6                  #2aa198
      color7                  #eee8d5
      color8                  #002b36
      color9                  #cb4b16
    '';

    home.file.".config/kitty/solarized-light.conf".text = ''
      background              #fdf6e3
      foreground              #657b83
      cursor                  #586e75
      selection_background    #475b62
      selection_foreground    #eae3cb
      color0                  #073642
      color1                  #dc322f
      color2                  #859900
      color3                  #b58900
      color4                  #268bd2
      color5                  #d33682
      color6                  #2aa198
      color7                  #eee8d5
      color8                  #002b36
      color9                  #cb4b16
      color10                 #586e75
      color11                 #657b83
      color12                 #839496
      color13                 #6c71c4
      color14                 #93a1a1
      color15                 #fdf6e3
    '';

    home.file.".config/kitty/kitty.conf".text = ''
        font_family Victor Mono
        
        allow_remote_control yes
        
        cursor_shape beam
        enable_audio_bell no
        font_size 12

    '';

    programs.git = {
      enable = true;
      userName = "Axel Gschaider";
      userEmail = "axel.gschaider@posteo.de";

      aliases = {
        wolf = "clean -i";
        tree = "log --all --graph --pretty=format:'%C(auto)%h%C(auto)%d %s %C(dim white)(%aN, %ar)'";
        pruned-tree = "log --graph --abbrev-commit --decorate --date=relative --all --simplify-by-decoration";
        patch = "!git --no-pager diff --no-color";
      };

      extraConfig = {
        core.editor = "vim";

        # -X does not clear the screen when exiting.
        # move between changed files with n/p
        pager.diff = "diff-so-fancy | less -iXFRS --pattern '^(Date|added|deleted|modified): '"; 
        
        push.default = "current";
        pull.ff = "only";
        safe.directory = "/etc/nixos";
      };

      ignores = [".factorypath"];

    };

    programs.ssh = {
        enable = true;

        matchBlocks = {
            "*" = {
                identityFile = "~/.ssh/id_rsa";
            };
            "10.0.0.89" = lib.hm.dag.entryBefore ["*"] {
                #hostname = "10.0.0.89";
                identityFile = "~/.ssh/id_rsa.gitsync";
            };
            "agschaid.mooo.com" = lib.hm.dag.entryBefore ["*"] {
                #hostname = "agschaid.mooo.com"
                identityFile = "~/.ssh/id_rsa.gitsync";
            };
        };

    };

    programs.qutebrowser = {
      enable = true;
      
      extraConfig = (builtins.readFile ./dotfiles/qutebrowser/extra_config.py);
      settings = {
        input = {
          spatial_navigation = true;
        };
      };

      aliases = {
        "b" = "buffer";
        "bd" = "tab-close";
      };

      keyBindings = {
        normal = {
        ",p" = "spawn --userscript password_fill";
        ",w" = "spawn -v -m wallabag_add {url}"; # this script is defined above
        "<ctrl+shift+l>" = ''config-cycle spellcheck.languages ["en-GB"] ["en-US"]'';
        "J" = "tab-prev";
        "K" = "tab-next";
        };
      };

    };

    programs.neovim = {
      enable = true;

      vimAlias = true;
      vimdiffAlias = true;
      viAlias = true;

      withPython3 = true;
      extraPython3Packages = ps: with ps; [pynvim msgpack];
      extraConfig =(builtins.readFile ./dotfiles/vim/vimrc);

      #coc = {
      #  enable = true;
      #  settings = {
      #    "java.home" = "/etc/jdk11";
      #    "languageserver" = {
      #        "elixirLS"= {
      #          "command"= "/home/agl/github/elixir-ls/release/language_server.sh";
      #          "filetypes"= ["elixir" "eelixir"];
      #        };
      #    };
      #  };
      #};

      plugins = with pkgs.vimPlugins; [
            goyo  # writing
            limelight-vim

            ##### versuchen
            # vim-pencil  # word wrapping und so
            # wheel . . . bisserl scrolling
            
            ctrlp
            fzf-vim
            vim-bufferline # shows list of buffers in command bar

            # ale
            coc-nvim
            nerdtree
	    minimap-vim
            vim-elixir
            # vim-markdown
            # tabular # needed by vim-markdown

            solarized
            { plugin = todo-txt-vim;
              # overwrite the date insertion and allow prio D instead
              # TODO does not work right now ;(
              config = "noremap <script> <silent> <buffer> <LocalLeader>d :call todo#txt#prioritize_add('D')<CR>";
            }

	    # vinegar # "better" netrw
	    telescope-nvim
          ];


    };
    

    programs.fish = {
      enable = true;
      
      functions = {

        fish_mode_prompt = "";

        fish_prompt = (builtins.readFile ./dotfiles/fish/functions/fish_prompt.fish);
      };

    };

    programs.tmux = {
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      shortcut = "a";
      keyMode = "vi";
      extraConfig = (builtins.readFile ./dotfiles/tmux/tmux.conf);


      plugins = with pkgs.tmuxPlugins; [
        # extrakto # texte mit fzf ins clipboard holen. Eh nett.
        # jump # j + erster Buchstabe. Dann bekommt man solche jump-to highlights
        # power-theme # powerline theme. Besser als gar nix.
        # tilish # TODO: mal ansehen! wie i3wm
      ];
    };

    # notification daemon
    services.dunst = {
      enable = true;
      # that's all for now
    };

    services.syncthing = {
      enable = true;
    };
    
    home.file.".config/fish/completions/pass.fish".source = ./dotfiles/fish/completions/pass.fish;
    home.file.".wezterm.lua".source = ./dotfiles/wezterm/wezterm.lua;
    home.file.".config/topydo/config".source = ./dotfiles/topydo/config;
    
  };
}


