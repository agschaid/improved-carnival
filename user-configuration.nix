let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    ref = "release-19.09";
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
                    "docker" ]; 
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
        push.default = "current";
      };

    };

    programs.vim = {
      enable = true;

      plugins = [];

      settings = {
        ignorecase = true;
        smartcase = true;
        number = true;
        background = "dark";
        mouse = "a";
      };

      extraConfig = ''
        set incsearch
      '';
    };


    /*programs.kitty = {
      enable = true;

      settings = {
        # Dark

        background =            "#002b36";
        foreground =            "#839496";
        cursor     =            "#93a1a1";
       
        selection_background =  "#81908f";
        selection_foreground =  "#002831";
        
        color0     =            "#073642";
        color1     =            "#dc322f";
        color2     =            "#859900";
        color3     =            "#b58900";
        color4     =            "#268bd2";
        color5     =            "#d33682";
        color6     =            "#2aa198";
        color7     =            "#eee8d5";
        color9     =            "#cb4b16";
        color8     =            "#002b36";
        color10    =            "#586e75";
        color11    =            "#657b83";
        color12    =            "#839496";
        color13    =            "#6c71c4";
        color14    =            "#93a1a1";
        color15    =            "#fdf6e3";
      };

    };*/
    
  };
}


