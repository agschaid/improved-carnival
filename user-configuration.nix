{config, pkgs, lib,...}:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    ref = "release-20.03";
  };

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
        kitty @set-colors --all --configured ~/.config/kitty/solarized-light.conf
        hsetroot -solid '#fdf6e3'
    else
        kitty @set-colors --all --configured ~/.config/kitty/solarized-dark.conf
        hsetroot -solid '#002b36'
    fi
  '';

  theme_local = pkgs.writeScriptBin "theme_local" ''
    #!${pkgs.stdenv.shell}
    if grep -q "light" ~/.theme; then
        kitty @set-colors ~/.config/kitty/solarized-light.conf
    else
        kitty @set-colors ~/.config/kitty/solarized-dark.conf
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

  customVimPlugins = {
    dwm-vim = pkgs.vimUtils.buildVimPlugin {
      name = "dwm-vim";
      src = pkgs.fetchFromGitHub {
        owner = "spolu";
        repo = "dwm.vim";
        rev = "6149e58fdd81f69e4e6a3f239842f3dc23e4872b";
        sha256 = "0ixnw6mxabgbpd702xdsrp9vp30iwa453pf89hli9wyzdz7ilg7p";
      };
    };
  };

in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.agl = {
    isNormalUser = true;
    extraGroups = [ "wheel" # Enable ‘sudo’ for the user.
                    "docker" 
                    "networkmanager" 
                  ]; 
    shell = pkgs.fish;
  };

  home-manager.users.agl = {

    xsession = {
      enable = true;

      profileExtra = "
      hsetroot -solid '#002b36' &
      setxkbmap de &";

      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
        config = ./dotfiles/xmonad.hs;
      };
    };

    home.sessionVariables = {
      EDITOR = "vim";
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
      theme_local
      light_theme
      dark_theme
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
      };

      extraConfig = {
        core.editor = "vim";
        core.pager = "less -iXFR"; # -X does not clear the screen when exiting
        push.default = "current";
      };

    };

    programs.neovim = {
      enable = true;

      vimAlias = true;
      vimdiffAlias = true;
      viAlias = true;

      withPython3 = true;
      extraPython3Packages = ps: with ps; [pynvim msgpack];

      configure = {

        customRC = ''
        set incsearch
        
        " buffers are hidden and not unloaded  -> switch between buffers without save
        set hidden
        
        set ignorecase
        set smartcase
        set number
        set background=dark
        set mouse=a

        set tabstop=4
        set shiftwidth=4
        set expandtab

        " make comments look pretty with Victor Mono
        highlight Comment cterm=italic gui=italic

        " show tabs and trailing whitespace. Use some less pronounced solarized color
        set list
        set listchars=tab:▸\ ,trail:·
        :hi BadWhitespace ctermfg=240 " Solarized Base01
        :match BadWhitespace / \+$/
        :2match BadWhitespace /\t/

        """ VALUES FOR SOLARIZED BRIGHT
        " let g:limelight_conceal_ctermfg = 245  " Solarized Base1
        " let g:limelight_conceal_guifg = '#8a8a8a'  " Solarized Base1
 
        """ VALUES FOR SOLARIZED DARK
        let g:limelight_conceal_ctermfg = 240  " Solarized Base01
        let g:limelight_conceal_guifg = '#585858'  " Solarized Base01

        let g:LanguageClient_serverCommands = {
            \ 'java': ['/home/agl/bin/jdtls', '-data', getcwd()],
            \ 'elixir': ['/home/agl/github/elixir-ls/release/language_server.sh']
            \ }

        nnoremap <silent> MM :call LanguageClient_contextMenu()<CR>
        nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
        nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>

        " needed by ncm2
        "let g:python3_host_prog = '/home/agl/.nix-profile/bin/python3'
        "autocmd BufEnter * call ncm2#enable_for_buffer()

        " NERDTREE CONFIG
        function BetterNerdTreeToggle()
            if &filetype == 'nerdtree' || exists("g:NERDTree") && g:NERDTree.IsOpen()
                :NERDTreeToggle
            elseif filereadable(expand('%'))
                NERDTreeFind
            else
                :NERDTree
            endif
        endfunction
        nnoremap <silent> NN :call BetterNerdTreeToggle()<CR>
        
        " show dot files by default
        let NERDTreeShowHidden=1
        :hi Directory ctermfg=4  " fix directory coloring of NerdTree

        " GOYO CONFIG
        " by default start in programming linebreak width
        let g:goyo_width = 120

        " CTRL-P CONFIG
        let g:ctrlp_custom_ignore = '\v[\/](target|dist|jdt.ls-java-project)|(\.(swp|ico|git|svn))$'

        " asdasdasd
        let g:ale_java_eclipselsp_path = '/home/agl/github/eclipse.jdt.ls'
        let g:ale_completion_enabled = 1
        let g:ale_linters = {
            \ 'java':['eclipselsp'],
        \}
      '';

        packages.myVimPackage = with pkgs.vimPlugins // customVimPlugins; {
          start = [
            goyo  # writing
            limelight-vim

            ##### versuchen
            # vim-pencil  # word wrapping und so
            # wheel . . . bisserl scrolling
            # syntastic  # syntax checking
            
            ctrlp
            fzf-vim
            vim-bufferline
            #vim-airline
            #vim-airline-themes

            # completers

            # ale
            LanguageClient-neovim
            #deoplete-lsp
            YouCompleteMe
            #coc-nvim
            # coc-java

            # nvim-yarp # needed by ncm2
            # ncm2
            nerdtree
            dwm-vim
            vim-elixir
          ];
        };

      };     

    };
    

    programs.fish = {
      enable = true;
      
      loginShellInit = "dark_theme";
      
      interactiveShellInit = "theme_local";
      
      functions = {

        fish_mode_prompt = "";

        fish_prompt = (builtins.readFile ./dotfiles/fish/functions/fish_prompt.fish);
      };

    };
    
    home.file.".config/fish/completions/pass.fish".source = ./dotfiles/fish/completions/pass.fish;
    
  };
}


