{ config, pkgs, inputs, ... }:

{
  # --- WAYLAND / COMPOSITOR (USER SESSION) ----------------------------------
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

  # --- DESKTOP / SHELL (USER-LEVEL) ------------------------------------------
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

}

