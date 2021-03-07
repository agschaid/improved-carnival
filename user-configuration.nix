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
      theme_local
      light_theme
      dark_theme
      diary
      oc_rsh
      oc_port_forward
      check_vehicle
      check_vehicle_history
      cut_gif
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
      };

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

        " always move in wrapped lines
        noremap <silent> k gk
        noremap <silent> j gj
        
        imap <A-f> (╯°□°)╯︵ ┻━┻
        imap <A-s> ¯\_(ツ)_/¯
        imap <A-d> (⌐■_■)
        imap <A-y> ┌П┐(ಠ_ಠ)
        imap <A-l> L(° O °L)


        set incsearch
        
        " buffers are hidden and not unloaded  -> switch between buffers without save
        set hidden

        " Don't write backups. Some language servers have issues with backup files, see coc #649.
        set nobackup
        set nowritebackup

        " Give more space for displaying messages.
        set cmdheight=2

        " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
        " delays and poor user experience. Needed by coc
        set updatetime=300
        
        " Don't pass messages to |ins-completion-menu|.
        " Needed by coc.
        set shortmess+=c

        
        set ignorecase
        set smartcase
        set number
        set background=dark
        set mouse=a

        set tabstop=2
        set shiftwidth=2
        set expandtab

        " make comments look pretty with Victor Mono
        highlight Comment cterm=italic gui=italic

        " show tabs and trailing whitespace. Use some less pronounced solarized color
        set list
        set listchars=tab:▸\ ,trail:·
        :hi BadWhitespace ctermfg=240 " Solarized Base01
        :match BadWhitespace / \+$/
        :2match BadWhitespace /\t/

        " general values for solarized plugin 
        let g:solarized_termtrans = 1
        set background=dark " not sure why but this should always be dark 
        colorscheme solarized

        """ VALUES FOR SOLARIZED BRIGHT
        " let g:limelight_conceal_ctermfg = 245  " Solarized Base1
        " let g:limelight_conceal_guifg = '#8a8a8a'  " Solarized Base1
 
        """ VALUES FOR SOLARIZED DARK
        let g:limelight_conceal_ctermfg = 240  " Solarized Base01
        let g:limelight_conceal_guifg = '#585858'  " Solarized Base01

        " nnoremap <silent> MM :call LanguageClient_contextMenu()<CR>
        " nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
        " nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>

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

        " GOYO QUIT: START
        " taken from https://github.com/junegunn/goyo.vim/wiki/Customization
        " When Goyo is open :q usually just quits Goyo. Not vim. The code below changes this behavior.
        function! s:goyo_enter()
          let b:quitting = 0
          let b:quitting_bang = 0
          autocmd QuitPre <buffer> let b:quitting = 1
          cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
        endfunction

        function! s:goyo_leave()
          " Quit Vim if this is the only remaining buffer
          if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
            if b:quitting_bang
              qa!
            else
              qa
            endif
          endif
        endfunction

        autocmd! User GoyoEnter call <SID>goyo_enter()
        autocmd! User GoyoLeave call <SID>goyo_leave()
        " GOYO QUIT: END

        " CTRL-P CONFIG
        let g:ctrlp_custom_ignore = '\v[\/](target|dist|jdt.ls-java-project)|(\.(swp|ico|git|svn))$'

        """""""
        " COC "
        """""""

        " Always show the signcolumn, otherwise it would shift the text each time
        " diagnostics appear/become resolved.
        if has("patch-8.1.1564")
          " Recently vim can merge signcolumn and number column into one
          set signcolumn=number
        else
          set signcolumn=yes
        endif

        " Use tab for trigger completion with characters ahead and navigate.
        " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
        " other plugin before putting this into your config.
        inoremap <silent><expr> <TAB>
              \ pumvisible() ? "\<C-n>" :
              \ <SID>check_back_space() ? "\<TAB>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> to trigger completion.
        if has('nvim')
          inoremap <silent><expr> <c-space> coc#refresh()
        else
          inoremap <silent><expr> <c-@> coc#refresh()
        endif

        " Make <CR> auto-select the first completion item and notify coc.nvim to
        " format on enter, <cr> could be remapped by other vim plugin
        inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

        " Use `[g` and `]g` to navigate diagnostics
        " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
        nmap <silent> <C-A-p> <Plug>(coc-diagnostic-prev)
        nmap <silent> <C-A-j> <Plug>(coc-diagnostic-next)

        " GoTo code navigation.
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)

        " Use K to show documentation in preview window.
        nnoremap <silent> K :call <SID>show_documentation()<CR>

        function! s:show_documentation()
          if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
          elseif (coc#rpc#ready())
            call CocActionAsync('doHover')
          else
            execute '!' . &keywordprg . " " . expand('<cword>')
          endif
        endfunction

        " Highlight the symbol and its references when holding the cursor.
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Symbol renaming.
        nmap <leader>rn <Plug>(coc-rename)

        " Formatting selected code.
        xmap <leader>f  <Plug>(coc-format-selected)
        nmap <leader>f  <Plug>(coc-format-selected)

        augroup mygroup
          autocmd!
          " Setup formatexpr specified filetype(s).
          autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
          " Update signature help on jump placeholder.
          autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        " Applying codeAction to the selected region.
        " Example: `<leader>aap` for current paragraph
        xmap <leader>a  <Plug>(coc-codeaction-selected)
        nmap <leader>a  <Plug>(coc-codeaction-selected)

        " Remap keys for applying codeAction to the current buffer.
        nmap <leader>ac  <Plug>(coc-codeaction)
        " Apply AutoFix to problem on the current line.
        nmap <leader>qf  <Plug>(coc-fix-current)

        " Map function and class text objects
        " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
        xmap if <Plug>(coc-funcobj-i)
        omap if <Plug>(coc-funcobj-i)
        xmap af <Plug>(coc-funcobj-a)
        omap af <Plug>(coc-funcobj-a)
        xmap ic <Plug>(coc-classobj-i)
        omap ic <Plug>(coc-classobj-i)
        xmap ac <Plug>(coc-classobj-a)
        omap ac <Plug>(coc-classobj-a)

        " Remap <C-f> and <C-b> for scroll float windows/popups.
        " Note coc#float#scroll works on neovim >= 0.4.3 or vim >= 8.2.0750
        "
        " enable when a newer coc version has arrived
        "
        "nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
        "nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
        "inoremap <nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
        "inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

        " Use CTRL-S for selections ranges.
        " Requires 'textDocument/selectionRange' support of language server.
        nmap <silent> <C-s> <Plug>(coc-range-select)
        xmap <silent> <C-s> <Plug>(coc-range-select)

        " Add `:Format` command to format current buffer.
        command! -nargs=0 Format :call CocAction('format')

        " Add `:Fold` command to fold current buffer.
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)

        " Add `:OR` command for organize imports of the current buffer.
        command! -nargs=0 OR   :call     CocAction(\'runCommand\', \'editor.action.organizeImport\')

        " Add (Neo)Vim's native statusline support.
        " NOTE: Please see `:h coc-status` for integrations with external plugins that
        " provide custom statusline: lightline.vim, vim-airline.
        set statusline^=%{coc#status()}%{get(b:,\'coc_current_function\',\'\')}

        " Mappings for CoCList
        " Show all diagnostics.
        nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
        " Manage extensions.
        nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
        " Show commands.
        nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
        " Find symbol of current document.
        nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
        " Search workspace symbols.
        nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
        " Do default action for next item.
        nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
        " Do default action for previous item.
        nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
        " Resume latest coc list.
        nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
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
            vim-bufferline # shows list of buffers in command bar

            # ale
            coc-nvim
            nerdtree
            dwm-vim
            vim-elixir
            vim-markdown

            solarized
          ];
        };

      };     

    };
    

    programs.fish = {
      enable = true;
      
      # loginShellInit = "dark_theme";
      
      # interactiveShellInit = "theme_local";
      
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
    };
    
    home.file.".config/fish/completions/pass.fish".source = ./dotfiles/fish/completions/pass.fish;
    
  };
}


