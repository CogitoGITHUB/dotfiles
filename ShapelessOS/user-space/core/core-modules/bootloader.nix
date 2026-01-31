{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # MAXIMUM boot debugging
  boot.kernelParams = [ 
    "boot.shell_on_fail"
    "systemd.log_level=debug"
    "rd.systemd.log_level=debug"
  ];
}
