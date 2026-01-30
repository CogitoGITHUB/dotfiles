{ config, pkgs, ... }:
{
  # Configure sops-nix for secret management
  sops = {
    # Path to encrypted secrets file
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    # Validate secrets exist at build time
    validateSopsFiles = true;
    
    age = {
      # Use SSH host key for decryption
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      
      # Fallback key file (auto-generated on first boot)
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    
    # Define secrets to decrypt
    secrets = {
      aoeu-password = {
        # Available before user creation
        neededForUsers = true;
        # Restrict permissions
        mode = "0400";
        owner = "root";
        group = "root";
      };
      
      # Add more secrets here as needed:
      # api-key = { };
      # database-password = { };
    };
  };
}
