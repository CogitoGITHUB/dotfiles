{ config, pkgs, ... }:

{
  services.grafana = {
    enable = false;  # enable when you want dashboards
  };

  # System health tooling
  environment.systemPackages = with pkgs; [
    lm_sensors
    smartmontools
    powertop
    glances
  ];

  # Optional watchdog patterns
   services.systemd-watchdog.enable = true;
}
