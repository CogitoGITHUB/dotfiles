{ config, pkgs, ... }:

{
  # Core monitoring services
  services.prometheus = {
    enable = false;  # enable when ready
  };

  services.prometheus.exporters = {
    node = {
      enable = false;  # enable later
      port = 9100;
    };
  };

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
  # services.systemd-watchdog.enable = true;
}
