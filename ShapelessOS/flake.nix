{
  description = "Shapeshifter flake";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    scroll-flake = {
      url = "github:AsahiRocks/scroll-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ self, nixpkgs, home-manager, scroll-flake, dms, sops-nix, ... }:
  let
    systemName = "shapeless";
  in
  {
    nixosConfigurations.${systemName} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit inputs;
        secretsPath = ./user-space/secrets;
      };
      modules = [
        # Hardware config (lowest level)
        ./hardware-configuration.nix
        
        # Kernel-space core loader (kernel, boot, low-level system)
        ./kernel-space/core/core-loader.nix
        
        # User-space core loader (system-level configs, services)
        ./user-space/core/core-loader.nix
        
        # External flakes (desktop environment, etc)
        scroll-flake.nixosModules.default
        dms.nixosModules.dank-material-shell
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        
        # Home-space loader (user environment)
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
        ./user-space/home/home-loader.nix
      ];
    };
  };
}
