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

      unstable_overlay = self: super:
      {
        kitty = unstable.kitty;
        
        # currently fails. But the version in the repos is really old and fails on contacts
        # vdirsyncer = unstable.vdirsyncer;
        
        prospector = unstable.prospector;
      };

      steam_overlay = self: super: 
      {
        steam = super.steam.override {
          extraPkgs = pkgs: [self.linux-pam];
        };
      };
    in
    [steam_overlay unstable_overlay];

  environment.systemPackages = with pkgs; 
    let 


      maven_jdk11 = maven.override {
        jdk = jdk11;
      };
      my-python-packages = python-packages: with python-packages; [
        pyyaml
        pip
        requests
        setuptools
      ];
      python-with-my-packages = python3.withPackages my-python-packages;

    in [
      killall
      wget 
      vim
      tmux
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
      jdk11
      jdk8
      maven_jdk11
      google-chrome
      thunderbird
      feh
      curl
      jq
      vscode
      kitty       # terminal
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
      sl          # muy importante
      sxiv        # image viewer
      xorg.libxcb # needed for steam
      postgresql
      zsh
      fzf
      # python-with-my-packages
      python37Full
      python37Packages.pip
      python37Packages.virtualenv
      python37Packages.pynvim
      python37Packages.flake8
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
      abcde
      networkmanager_dmenu
      nms  # no more secrets effect ;)
      nvpy # notational veolicity?
      stern
      
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
    ];

  fonts.fonts = with pkgs; [
      victor-mono # terminal font
  ];

  environment.etc = with pkgs; {
    "jdk".source = jdk;
    "jdk8".source = jdk8;
    "jdk11".source = jdk11;
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

  # services.xserver.displayManager.ly.enable = true;


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?

}

