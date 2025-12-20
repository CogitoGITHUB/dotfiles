{ config, pkgs, inputs, noctalia, ... }:

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
  networking.hostName = "shapeless";  # rename from "nixos"
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
  extraGroups = [ "networkmanager" "wheel" "docker" ];
  shell = pkgs.nushell;

  packages = with pkgs; [
    docker-compose

    # Kubernetes swordset
    kubectl
    k9s
    helm

    # Observability
    prometheus
    grafana

    # Mesh sorcery (choose one)
    istioctl
    linkerd

    # Ingress gatekeepers
    traefik
    nginx

    # Lens (warning: heavy GUI, remove if you want CLI-only purity)
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
      Policy = {
        AutoEnable = true;
      };
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
    XDG_DESKTOP_PORTAL_DIR = "/run/current-system/sw/share/xdg-desktop-portal/portals";
    XDG_DESKTOP_PORTAL_BACKEND = "wlr";
  };

  # --- WAYLAND / COMPOSITOR --------------------------------------------------
  programs.niri.enable = true;

  # --- UNFREE ---------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;

  # --- OPTIONAL PROGRAMS -----------------------------------------------------
  programs.steam.enable = true;



  # Required services for Noctalia features
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;


services.tailscale.enable = true;
services.tailscale.extraSetFlags = ["--netfilter-mode=nodivert"];


services.logind.settings.Login.HandleLidSwitch = "ignore";
services.logind.settings.Login.HandleLidSwitchDocked = "ignore";



  # --- DOCKER ---------------------------------------------------------------
  virtualisation.docker.enable = true;

# --- KUBERNETES (K3S) ------------------------------------------------------
services.k3s = {
  enable = true;
  role = "server";
  clusterInit = true;
  extraFlags = [ "--docker" ];
};


systemd.services.k3s.enable = false;
systemd.services."tailscaled-set".enable = false;


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


inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default



    qemu

    waydroid-nftables
    waydroid
    waydroid-helper

    krita

    xwayland-satellite
    tmux
    qutebrowser
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    fuzzel
    gimp
    inkscape
    emacs
    nodejs
    gcc
    tree-sitter
    nyxt
    lsd
    htop
    bluetui
    exiftool
    bat
    zathura
    zellij
    wezterm
    nb
    ffmpeg
    python3
    python3Packages.mutagen
    neovim
    mpd
    mpdcron
    cava
    rmpc
    fastfetch
    evtest
    git
    lazygit
    gh
 jujutsu
jj-fzf
lazyjj
starship
    wl-clipboard
    atuin
    fzf
    zoxide
    obs-studio
    obs-cli
    blender
    mpv
    mpvpaper
    yt-dlp
    wget
    texlive.combined.scheme-full
    texlivePackages.latexmk
    ghostscript
zip
texinfo
 cmake          # required for vterm-module compilation
    gcc            # build tools

];

  # --- SSH -------------------------------------------------------------------
  services.openssh.enable = true;

  # --- SYSTEM VERSION --------------------------------------------------------
  system.stateVersion = "25.05";
}
