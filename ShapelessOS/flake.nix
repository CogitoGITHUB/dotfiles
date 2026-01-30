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
    systemName = "shapeless";  # Changed back to lowercase - convention
  in
  {
    nixosConfigurations.${systemName} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Hardware config
        ./hardware-configuration.nix
        
        # External flakes
        scroll-flake.nixosModules.default
        dms.nixosModules.dank-material-shell
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        
        # Core loader - automatically imports all modules and packages
        ./user-space/core/core-loader.nix
        
        # Home manager configuration
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users = {
            aoeu = import ./puppets/aoeu.nix;  # Assuming you moved user configs to puppets
          };
        }
      ];
    };
  };
}