{ config, pkgs, inputs, noctalia, ... }:
{
  # Required by home-manager
  home.username = "asdf";
  home.homeDirectory = "/home/asdf";
  home.stateVersion = "25.05";
  
  imports = [
    inputs.noctalia.homeModules.default
  ];
}