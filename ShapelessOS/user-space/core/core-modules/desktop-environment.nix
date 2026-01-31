{ config, pkgs, inputs, ... }:

{
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

  # --- GRAPHICS --------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # --- SHELL / DESKTOP LAYER --------------------------------------------------
  programs.dank-material-shell = {
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

  # --- SEAT / INPUT SESSION --------------------------------------------------
  services.seatd.enable = true;

services.mako = {
  enable = true;
};

}
