{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Extreme boot debugging
  boot.kernelParams = [ 
    "boot.shell_on_fail"
    "systemd.log_level=debug"
    "systemd.log_target=console"
    "rd.systemd.log_level=debug"
  ];
  
  # Don't let any script kill boot
  systemd.enableEmergencyMode = true;
}
