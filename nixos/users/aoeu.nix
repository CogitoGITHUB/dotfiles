{ config, pkgs, ... }:

{
  home.username = "aoeu";
  home.homeDirectory = "/home/aoeu";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}

