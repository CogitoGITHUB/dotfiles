{ config, pkgs, ... }:

{
  users.users.aoeu = {
    isNormalUser = true;
    description = "aoeu";
    extraGroups = [ "uinput" "seat" "video" "render" "networkmanager" "wheel" "docker" ];
    shell = pkgs.nushell;
    hashedPasswordFile = config.sops.secrets.aoeu-password.path;
  };
}
