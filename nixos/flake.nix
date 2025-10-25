{
  description = "NixOS flake with Hyprland and several community plugins.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";

    # Official Plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Custom Plugin: hyprland-easymotion
    hyprland-easymotion = {
      url = "github:zakk4223/hyprland-easymotion";
      inputs.hyprland.follows = "hyprland";
    };

    # Custom Plugin: hypr-dynamic-cursors
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };
    # The 'hyprscroll' input has been removed as the plugin is now in 'hyprland-plugins'
  };

  # Removed hyprscroll from the outputs list
  outputs = { self, nixpkgs, hyprland, hyprland-plugins, hyprland-easymotion, hypr-dynamic-cursors, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
    in {
      nixosConfigurations.mySystem = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
          ./hardware-configuration.nix

          {
            programs.hyprland = {
              enable = true;
              package = inputs.hyprland.packages.${system}.hyprland;
            };

            # 🧩 Set up HYPR_PLUGIN_DIR by symlinking all plugins from all inputs
            environment.sessionVariables = {
              HYPR_PLUGIN_DIR = pkgs.symlinkJoin {
                name = "hyprland-plugins-all";
                paths = [
                  # Official Plugins
                  inputs.hyprland-plugins.packages.${system}.hyprfocus
                  inputs.hyprland-plugins.packages.${system}.hyprexpo
                  inputs.hyprland-plugins.packages.${system}.hyprwinwrap
                  
                  # ADDED: The renamed scrolling plugin from the official repo
                  inputs.hyprland-plugins.packages.${system}.hyprscrolling 
                  
                  # EasyMotion Plugin
                  inputs.hyprland-easymotion.packages.${system}.hyprland-easymotion

                  # Dynamic Cursors Plugin
                  inputs.hypr-dynamic-cursors.packages.${system}.hypr-dynamic-cursors
                ];
              };
            };
          }
        ];
      };
    };
}
