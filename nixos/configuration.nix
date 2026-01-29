{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # --- FLAKE ENABLEMENT ------------------------------------------------------
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # --- HOST ------------------------------------------------------------------
  networking.hostName = "shapeless";
  networking.networkmanager.enable = true;

  # --- TIME & LOCALE ---------------------------------------------------------
  time.timeZone = "Europe/Bucharest";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  # --- BOOTLOADER ------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --- SOUND (PIPEWIRE) ------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # --- USER ------------------------------------------------------------------
  users.users.aoeu = {
    isNormalUser = true;
    description = "aoeu";
    extraGroups = [ "uinput" "seat" "video" "render" "networkmanager" "wheel" "docker" ];
    shell = pkgs.nushell;
    packages = with pkgs; [
    ];
  };

  # --- BLUETOOTH -------------------------------------------------------------
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy.AutoEnable = true;
    };
  };

  # --- FONTS -----------------------------------------------------------------
  fonts.packages = with pkgs; [
    tangerine
  ];

# TTY settings
console.keyMap = "dvorak";


  # --- PORTALS ---------------------------------------------------------------
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal-gtk
  ];
  # --- WAYLAND / COMPOSITOR --------------------------------------------------
  programs.scroll = {
    enable = true;
    package =
      inputs.scroll-flake.packages.${pkgs.stdenv.hostPlatform.system}.scroll-git;

    extraSessionCommands = ''
      export QT_QPA_PLATFORM="wayland;xcb"
      export GDK_BACKEND="wayland,x11"
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland
      export ELECTRON_OZONE_PLATFORM_HINT=wayland
    '';
  };

  # --- UNFREE ---------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  # --- GRAPHICS --------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # --- STEAM -----------------------------------------------------------------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # --- POWER / LOGIN ---------------------------------------------------------
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # --- NETWORKING ------------------------------------------------------------
services.tailscale.enable = true;
services.tailscale.extraSetFlags = [
  "--netfilter-mode=nodivert"
  "--accept-dns=false"
];



  # --- DOCKER ---------------------------------------------------------------
  virtualisation.docker.enable = true;

  # --- KUBERNETES (K3S) ------------------------------------------------------
  services.k3s = {
    enable = false;
    role = "server";
    clusterInit = true;
    extraFlags = [ "--docker" ];
  };


programs.dankMaterialShell = {
  enable = true;
  systemd.enable = false;
  systemd.restartIfChanged = false;
  quickshell.package = pkgs.quickshell;
  enableSystemMonitoring = true;
  enableVPN              = true;
  enableDynamicTheming   = true;
  enableAudioWavelength  = true;
  enableCalendarEvents   = true;
};



services.seatd.enable = true;


services.ollama = {
    enable = true;
    package = pkgs.ollama-cpu;  # CPU-only version
};

# --- SYSTEM PACKAGES -------------------------------------------------------
  environment.systemPackages = with pkgs; [
    pass
    ollama
    rofi
    cargo
    docker
    
    lazydocker
    docker-compose
    k3s
    kubectl
    helm
    k9s
    gemini-cli
    opencode
    ardour
    lmms
    hydrogen
    fluidsynth
    supercollider
    sox
    sonic-pi

    qemu
    waydroid
    waydroid-nftables
    waydroid-helper

    krita
    gimp
    inkscape
    blender

    emacs
    neovim
    gcc
    cmake
    libtool
    tree-sitter
    nodejs
    python3
    python3Packages.mutagen

    tmux
    zellij
    wezterm
    starship
    nushell

    qutebrowser
    nyxt
    zathura
    mpv
    mpvpaper
    yt-dlp
    ffmpeg

    mpd
    mpdcron
    cava
    rmpc

    git
    lazygit
    gh

    bat
    lsd
    htop
    fastfetch
    bluetui
    exiftool
    evtest
    wl-clipboard
    atuin
    fzf
    zoxide

    obs-studio
    obs-cli

    texlive.combined.scheme-full
    texlivePackages.latexmk
    ghostscript
    texinfo
    poppler
    zip
    wget


    # LSP servers
  lua-language-server  # lua_ls
  pyright             # Python
  nodePackages.typescript-language-server  # TypeScript/JavaScript
  texlab              # LaTeX (you already have this via texlive)


  ];


# Make sure uinput group exists ( katana )
users.groups.uinput = {};


services.kanata = {
  enable = true;
  keyboards = {
    internalKeyboard = {
      extraDefCfg = "process-unmapped-keys yes";
      config = ''
        (defsrc
         caps a o e u h t n s
        )
        (defvar
         tap-time 150
         hold-time 200
        )
        (defalias
         caps (tap-hold 100 100 esc lctl)
         a (tap-hold $tap-time $hold-time a lmet)
         o (tap-hold $tap-time $hold-time o lalt)
         e (tap-hold $tap-time $hold-time e lsft)
         u (tap-hold $tap-time $hold-time u lctl)
         h (tap-hold $tap-time $hold-time h rctl)
         t (tap-hold $tap-time $hold-time t rsft)
         n (tap-hold $tap-time $hold-time n ralt)
         s (tap-hold $tap-time $hold-time s rmet)
        )
        (deflayer base
         @caps @a  @o  @e  @u  @h  @t  @n  @s
        )
      '';
    };
  };
};


# --- SSH -------------------------------------------------------------------
  services.openssh.enable = true;

  # --- SYSTEM VERSION --------------------------------------------------------
  system.stateVersion = "25.05";
}
