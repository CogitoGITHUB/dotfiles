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
  users.users.asdf = {
    isNormalUser = true;
    description = "asdf";
    extraGroups = [ "video" "render" "networkmanager" "wheel" "docker" ];
    shell = pkgs.nushell;

    packages = with pkgs; [
      docker-compose
      kubectl
      k9s
      helm
      prometheus
      grafana
      istioctl
      linkerd
      traefik
      nginx
      lens
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

  # --- PORTALS ---------------------------------------------------------------
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal-gtk
  ];

  environment.variables = {
    XDG_CURRENT_DESKTOP = "scroll";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "scroll";
    XDG_DESKTOP_PORTAL_BACKEND = "wlr";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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
  services.tailscale.extraSetFlags = [ "--netfilter-mode=nodivert" ];

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
  systemd.enable = true;
  systemd.restartIfChanged = true;
  quickshell.package = pkgs.quickshell;
  enableSystemMonitoring = true;
  enableClipboard        = true;
  enableVPN              = true;
  enableDynamicTheming   = true;
  enableAudioWavelength  = true;
  enableCalendarEvents   = true;
};

# Add these environment variables for the graphical session
environment.sessionVariables = {
  QT_QPA_PLATFORM = "wayland";
  WAYLAND_DISPLAY = "wayland-1";
};


# --- SYSTEM PACKAGES -------------------------------------------------------
  environment.systemPackages = with pkgs; [
    docker
    lazydocker
    docker-compose
    k3s
    kubectl
    helm
    k9s
    n8n
    gemini-cli

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
    fuzzel
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
    jujutsu
    jj-fzf
    lazyjj

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
  ];

  # --- SSH -------------------------------------------------------------------
  services.openssh.enable = true;

  # --- SYSTEM VERSION --------------------------------------------------------
  system.stateVersion = "25.05";
}
