# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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

        jdk16 = unstable.jdk16; # currently only in unstable
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

    in
    [steam_overlay unstable_overlay src_overlays];

  environment.systemPackages = with pkgs; 
    let 


      maven_jdk16 = maven.override {
        jdk = jdk16;
      };

    in [
      killall
      wget 
      vim
      tmux
      dvtm # terminal multiplexer
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
      pass
      # pinentry   # gpg needs it . . . 
      atom
      syncthing
      tree
      zip
      unzip
      jdk16
      jdk11
      jdk8
      maven_jdk16
      google-chrome
      thunderbird
      feh
      curl
      jq
      vscode
      kitty       # terminal
      st
      scroll

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
      python37Full
      python37Packages.pip
      python37Packages.virtualenv
      python37Packages.pynvim
      python37Packages.flake8
      python37Packages.setuptools
      # prospector
      mypy
      python37Packages.pyflakes



      steam-run
      #google-authenticator
      #linux-pam
      #libcap_pam
      #pam_pgsql
      #openpam
      # nodejs # for coc.nvim
      aerc
      qutebrowser
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

      gimp
      libreoffice
      postman

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
      gradle

      steam
      hugo    # site generator
      deltachat-electron
      renameutils
      josm
      wmname
      libnotify
      signal-desktop
      signal-cli

      flameshot # screenshot
      httpie

      hydrogen
      musescore

    ];

  fonts.fonts = with pkgs; [
      victor-mono # terminal font
  ];

  environment.etc = with pkgs; {
    "jdk".source = jdk;
    "jdk8".source = jdk8;
    "jdk11".source = jdk11;
    "jdk16".source = jdk16;
  };

  environment.pathsToLink = ["/share/zsh"];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.gnupg.agent = { enable = true; };

  programs.adb.enable = true;

  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    tapButtons = false;
    palmDetect = true;

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

