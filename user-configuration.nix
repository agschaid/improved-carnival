{config, pkgs, lib,...}:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    ref = "release-20.03";
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
    shell = pkgs.zsh;
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
            \ }

        " maybe I should delete these . . .
        let g:airline_theme='solarized'
        let g:airline_solarized_bg='dark'
        let g:airline#extensions#tabline#enabled = 1
        let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
        " let g:airline#extensions#tabline#tab_nr_type = 2
        let g:airline#extensions#tabline#show_tab_nr = 1

        nnoremap <silent> MM :call LanguageClient_contextMenu()<CR>
        nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
        nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>

        " needed by ncm2
        "let g:python3_host_prog = '/home/agl/.nix-profile/bin/python3'
        "autocmd BufEnter * call ncm2#enable_for_buffer()
      '';

        packages.myVimPackage = with pkgs.vimPlugins; {
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

            LanguageClient-neovim
            youcompleteme
            #coc-nvim
            # coc-java

            # nvim-yarp # needed by ncm2
            # ncm2
          ];
        };

      };     

    };
    
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      autocd = true;
      defaultKeymap = "viins";

      oh-my-zsh = {
        enable = true;
        theme = "bira";
        plugins = 
          [
            # "zsh-notes" # nv ähnlich
          ];
      };
    };

    programs.kitty = {
      enable = true;

      # mal versuchen:
      font.package = pkgs.victor-mono;
      font.name = "Victor Mono";

      settings = {
        enable_audio_bell = false;

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

    };
    
  };
}


