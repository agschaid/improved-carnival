# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./vpn-configuration.nix
      ./user-configuration.nix
    ];


  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      name = "root";
      device = "/dev/disk/by-uuid/bf3c2bf2-a024-4377-8438-47fff4a154a5";
      preLVM = true;
      allowDiscards = true;
    };
  };

  networking.hostName = "langeoog"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.extraHosts = let
    hostsPath = https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts;
    hostsFile = builtins.fetchurl hostsPath;
  in builtins.readFile "${hostsFile}";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = 
    let
      # using unstable. Do to install unstable as alternative path:
      #
      # sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
      # sudo nix-channel --update

      unstable = import <nixos-unstable> { config = config.nixpkgs.config; };

      # HOWTO get sha256: https://github.com/NixOS/nix/issues/1880
      # nix-prefetch-url --unpack githuburl<rev>.tar.gz

      st_src = pkgs.fetchFromGitHub {
            owner  = "agschaid";
            repo   = "st";
            rev    = "f70528ec465fd634256fec6140c327a2dad6c4c7";
            sha256 = "1p010nhm2r45ipji6l5xsiqjzjp5j6j6w1sc50x6kmy4dssy0yip";
        };

      scroll_src = pkgs.fetchFromGitHub {
        owner  = "agschaid";
        repo   = "scroll";
        rev    = "a3078d4e5c956b9cfe483c8f500c8994d01e54d0";
        sha256 = "1d1lsqafkcia3s86cbmpgw7dz9qp5mwra8s0cg5x3a86p81cl1ca";
      };

      unstable_overlay = self: super:
      {
        kitty = unstable.kitty;
        
        # currently fails. But the version in the repos is really old and fails on contacts
        # vdirsyncer = unstable.vdirsyncer;
        
        prospector = unstable.prospector;

        deltachat-electron = unstable.deltachat-electron;

        nushell = unstable.nushell;

        #adoptJdk16 = unstable.adoptopenjdk-openj9-bin-16; # currently only in unstable
        #jdk17 = unstable.jdk17;

        maven = unstable.maven;

        # wezterm = unstable.wezterm; # currently only in unstable

        # gradle_7 = unstable.gradle_7;

	# pass-otp = unstable.pass-otp;

	zellij = unstable.zellij;

	glab = unstable.glab;

	tdesktop = unstable.tdesktop;
	signal-desktop = unstable.signal-desktop;
        google-chrome = unstable.google-chrome;

        stack = unstable.stack;

        kubectl = unstable.kubectl;
        ghc = unstable.ghc;
        ghcid = unstable.ghcid;
        haskell-language-server = unstable.haskell-language-server;
      };

      steam_overlay = self: super: 
      {
        steam = super.steam.override {
          extraPkgs = pkgs: [self.linux-pam];
        };
      };

      src_overlays = self: super: {
        st = import "${st_src}/default.nix";
        scroll = import "${scroll_src}/default.nix";
      };

      extensions_overlay = self: super: {
	pass-with-otp = (super.pass.withExtensions (ext: with ext; [pass-otp]));
      };

    in
    [steam_overlay unstable_overlay src_overlays extensions_overlay];

  environment.systemPackages = with pkgs; 
    let 


      #maven_jdk16 = maven.override {
      #  jdk = adoptJdk16;
      #};

      #gradle7_jdk17 = gradle_7.override {
      #    java = jdk17;
      #};

      #ghc822pkgs = import (builtins.fetchGit {
      #   # Descriptive name to make the store path easier to identify
      #   name = "nixpgks_with_ghc_8_8_2";
      #   url = "https://github.com/NixOS/nixpkgs/";
      #   ref = "refs/heads/nixpkgs-unstable";
      #   rev = "92a047a6c4d46a222e9c323ea85882d0a7a13af8";
      #}) {};

    in [
      killall
      wget 
      vim
      tmux
      dvtm # terminal multiplexer
      wezterm
      git
      tig
      gnupg1
      htop
      firefox
      dmenu

      # does not quite work. Investigate
      # networkmanager_dmenu
      # networkmanager

      xclip
      pass-with-otp     # version of pass including the otp plugin
      # pinentry   # gpg needs it . . . 
      # atom
      syncthing
      tree
      zip
      unzip
      #adoptJdk16
      # jdk11
      #jdk8
      #jdk17
      #maven_jdk16
      #maven
      google-chrome
      thunderbird
      evolution
      feh
      curl
      jq
      #vscode
      kitty       # terminal
      st
      scroll
      zellij

      zathura     # pdf
      unclutter
      hsetroot
      gmrun       # run dialog für xmonad
      # gksudo    # graphical sudo
      acpi        # battery status
      xorg.xrandr # screens anordnen
      arandr      # frontend für xrandr
      mplayer     # video
      ffmpeg      # basis video schnitt
      imagemagick

      ctags    # für vim. Solle ich vielleicht dort hin schieben
      
      ############ MUY IMPORTANTE
      sl          # eh scho wissen
      gti         # wie sl für git
      nms         # no more secrets effect ;)
      bastet      # tetris. Aber schwer
      
      sxiv        # image viewer
      xorg.libxcb # needed for steam
      postgresql
      zsh
      fzf
      lftp # ftp client for terminal
      # python37Full
      # python37Packages.pip
      # python37Packages.virtualenv
      # python37Packages.pynvim
      # python37Packages.flake8
      # python37Packages.setuptools
      # mypy
      # python37Packages.pyflakes



      steam-run
      #google-authenticator
      #linux-pam
      #libcap_pam
      #pam_pgsql
      #openpam
      # nodejs # for coc.nvim
      aerc
      qutebrowser
      #torbrowser
      rofi
      abcde
      networkmanager_dmenu
      nvpy # notational veolicity?
      stern
      nushell
      mtm   # minimal multiplexer
      
      gparted
      
      # filemanagers. Just one. Or none.
      nnn
      spaceFM

      ghc # haskell
      ghcid
      #ghc822pkgs.ghc
      stack
      cabal-install
      haskell-language-server

      khal
      khard
      vdirsyncer
      
      gitAndTools.diff-so-fancy
      mdcat

      bc # calculator
      nodejs

      lynx
      links2
      w3m-full

      #gimp
      #libreoffice
      #postman

      yq

      arp-scan
      lolcat
      youtube-dl
      entr

      p7zip
      muse
      tdesktop
      ncdu
      exercism
      rebar3
      #gradle7_jdk17

      steam
      hugo    # site generator
      deltachat-electron
      renameutils
      josm
      wmname
      libnotify
      signal-desktop

      flameshot # screenshot
      httpie

      hydrogen
      musescore

      mullvad-vpn

      glab
      # lmms # for creating music n stuff
      tdesktop # telegram
      threema-desktop

      git-annex

      handbrake # eh scho wissen. DVD Ripper

      ripgrep

      vlc

      extremetuxracer
      superTuxKart
      opendune

      # pipewire # audio. weil es David Herberth sagt
      topydo # recht netter python client für todo.txt -> columns

      kid3 # id3 tags -> ui und shell

      abiword # for allem für Wildflowers. Kann danach wohl wieder weg

      # kube-stuff for work
      minikube
      kubectl
      k9s
      gettext # for envsubst


      tldr

      silver-searcher

      # exercism languages 2023
      julia-bin
      php
      pdfgrep
      #jetbrains.idea-community
    ];

  fonts.fonts = with pkgs; [
      victor-mono # terminal font
  ];

  #environment.etc = with pkgs; {
  #  "jdk".source = jdk17;
  #  "jdk8".source = jdk8;
  #  #"jdk11".source = jdk11;
  #  #"jdk16".source = adoptJdk16;
  #  "jdk17".source = jdk17;
  #};

  environment.pathsToLink = ["/share/zsh"];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.gnupg.agent = { enable = true; };

  programs.adb.enable = true;

  # we need to enable it here so we can set it as shell in the user definition
  programs.fish.enable = true;

  #programs.java = with pkgs; {
  #  enable = true;
  #  package = jdk17;
  #};

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.mullvad-vpn.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 
    22000 # syncthing
  ];
  networking.firewall.allowedUDPPorts = [ 
    21025 # syncthing
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    # needed for Steam
    support32Bit = true;
  };

  # Enable the X11 windowing system.

  services.xserver = {
    enable = true;

    # I really don't know why but setting the layout does not seem to work. Maybe xmonad ignores it?
    layout = "de";
    xkbOptions = "eurosign:e";

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPackages: [
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
        haskellPackages.xmonad
      ];
    };

  };

  virtualisation.docker.enable = true;


  # Enable touchpad support.

  ## "something" activates libinput (which cant' be used together with synaptics).
  # services.xserver.synaptics = {
  #  enable = true;
  #  twoFingerScroll = true;
  #  tapButtons = false;
  #  palmDetect = true;
  #};
  services.xserver.libinput.touchpad = {
    # ???
    clickMethod = "none";
    disableWhileTyping = true;
    tapping = false;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.cron.enable = true;
  # services.xserver.displayManager.ly.enable = true;


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?

}

