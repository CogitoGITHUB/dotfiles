{ config, pkgs, lib, ... }:
{
  # Automatic ISO building and old generation cleanup
  
  # Build ISO after successful rebuild
  system.activationScripts.buildIso = lib.stringAfter [ "etc" ] 
    # Only run if not building in a VM
    if [ ! -e /run/current-system/sw/bin/qemu-system-x86_64 ]; then
      echo "Skipping ISO build in VM environment"
      exit 0
    fi
    
    # Build ISO in background
    ${pkgs.writeShellScript "build-iso-bg" 
      #!/usr/bin/env bash
      set -e
      
      ISO_DIR="/home/aoeu/.config/ShapelessOS/iso"
      mkdir -p "$ISO_DIR"
      
      cd /home/aoeu/.config/ShapelessOS
      
      # Build ISO
      echo "Building ShapelessOS ISO..."
      nix build .#nixosConfigurations.shapeless.config.system.build.isoImage \
        --out-link "$ISO_DIR"/result \
        2>&1 | logger -t iso-builder
      
      # Create timestamped symlink
      if [ -e "$ISO_DIR/result/iso" ]; then
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        ln -sf result/iso/*.iso "$ISO_DIR/shapeless-$TIMESTAMP.iso" 2>/dev/null || true
        
        # Keep only last 3 ISOs
        cd "$ISO_DIR"
        ls -t shapeless-*.iso 2>/dev/null | tail -n +4 | xargs -r rm -f
        
        echo "ISO built successfully: $ISO_DIR/shapeless-$TIMESTAMP.iso"
      fi
    } &
  ;
  
  # Automatic generation cleanup after successful rebuild
  system.activationScripts.cleanupGenerations = lib.stringAfter [ "etc" ] 
    echo "Cleaning up old NixOS generations..."
    
    # Keep last 5 generations
    ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +5
    
    # Collect garbage
    ${pkgs.nix}/bin/nix-collect-garbage -d
    
    # Optimize store
    ${pkgs.nix}/bin/nix-store --optimize
    
    echo "Generation cleanup complete"
  ;
  
  # Enable automatic store optimization
  nix.settings.auto-optimise-store = true;
  
  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
