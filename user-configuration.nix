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
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  home-manager.users.agl = {

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


    
  };
}


