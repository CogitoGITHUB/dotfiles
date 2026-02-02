{ config, pkgs, lib, ... }:
{
  # ===========================================================================
  # AUTO LOGIN
  # ===========================================================================
  services.getty.autologinUser = "aoeu";

  # Lid switch — use the new option paths that NixOS expects
  services.logind.settings.Login = {
    HandleLidSwitch         = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked   = "ignore";
  };
}
