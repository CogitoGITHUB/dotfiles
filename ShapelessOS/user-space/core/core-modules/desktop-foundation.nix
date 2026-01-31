{ config, pkgs, ... }:

{
  xdg.portal.enable = true;

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.seatd.enable = true;
}

