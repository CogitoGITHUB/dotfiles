{ config, pkgs, ... }:

{

  # System health tooling
  environment.systemPackages = with pkgs; [
    lm_sensors
    smartmontools
    powertop
    glances
  ];

}
