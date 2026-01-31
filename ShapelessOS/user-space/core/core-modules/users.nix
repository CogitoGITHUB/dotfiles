{ config, pkgs, ... }:
{
  users.users.aoeu = {
    isNormalUser = true;
    description = "aoeu";
    extraGroups = [ "uinput" "seat" "video" "render" "networkmanager" "wheel" "docker" ];
    shell = pkgs.nushell;
    # Simple password instead of sops
    password = "aoeu";  # Change this to whatever you want
  };
  
  users.groups.uinput = {};
}
