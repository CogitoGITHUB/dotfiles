{
  description = "Shapeshifter's minimal NixOS configuration with Scroll";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    scroll-flake = {
      url = "github:AsahiRocks/scroll-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ nixpkgs, scroll-flake, dms, ... }:
  {
    nixosConfigurations.shapeless = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        scroll-flake.nixosModules.default
        # Use the correct module name
        dms.nixosModules.dankMaterialShell
        ./configuration.nix
      ];
    };
  };
}