{
  description = "Shapeshifter's NixOS configuration with Noctalia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, noctalia, home-manager, ... }:

    # ---------------- PACKAGES FOR OTHER SYSTEMS -----------------------------
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.hello;
      }
    )
    //

    # ------------------- NIXOS CONFIGURATION --------------------------------
    {
      nixosConfigurations.shapeless = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # specialArgs go to *NixOS* modules
        specialArgs = {
          inherit inputs noctalia;
        };

        modules = [
          {
            nixpkgs.overlays = [ ];
          }

          ./configuration.nix

          # -------- HOME MANAGER WIRING -------------------------------------
          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # extraSpecialArgs go to *home-manager* modules (like home.nix)
            home-manager.extraSpecialArgs = {
              inherit inputs noctalia;
            };

            home-manager.users.asdf = import ./home.nix;
          }
        ];
      };
    };
}
