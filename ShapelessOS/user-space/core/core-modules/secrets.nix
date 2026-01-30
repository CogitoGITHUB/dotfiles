{ config, pkgs, ... }:

{
  # Configure sops-nix
  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      # Automatically use SSH host key
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      # Fallback key file location
      keyFile = "/var/lib/sops-nix/key.txt";

      # Auto-generate key if it doesn't exist
      generateKey = true;
    };

    secrets = {
      aoeu-password = {
        neededForUsers = true;
      };
    };
  };
}
