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
  };

  outputs = inputs@{ self, nixpkgs, home-manager, scroll-flake, dms, ... }:
  let
    lib = nixpkgs.lib;

    findNixFiles = dir:
      let
        entries = builtins.readDir dir;
        files = lib.filter (name: lib.hasSuffix ".nix" name && entries.${name} == "regular")
          (builtins.attrNames entries);
        dirs = lib.filter (name: entries.${name} == "directory")
          (builtins.attrNames entries);
      in
        map (f: "${dir}/${f}") files
        ++ lib.concatMap (d: findNixFiles "${dir}/${d}") dirs;

    findUserFiles = dir:
      let
        entries = builtins.readDir dir;
        files = lib.filter (name: lib.hasSuffix ".nix" name && entries.${name} == "regular")
          (builtins.attrNames entries);
        dirs = lib.filter (name: entries.${name} == "directory")
          (builtins.attrNames entries);
      in
        map (f: { name = lib.removeSuffix ".nix" f; file = "${dir}/${f}"; }) files
        ++ lib.concatMap (d: findUserFiles "${dir}/${d}") dirs;

    kernelModules = findNixFiles ./kernel-space/kernel-modules;
    coreModules = findNixFiles ./user-space/core/core-modules;
    homeModules = findNixFiles ./user-space/home/home-modules;
    userConfigs = builtins.listToAttrs (
      map (u: { name = u.name; value = import u.file; }) (findUserFiles ./user-space/home/users)
    );
  in
  {
    nixosConfigurations.shapeless = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules =
        [ ./hardware-configuration.nix ]
        ++ kernelModules
        ++ [
          scroll-flake.nixosModules.default
          dms.nixosModules.dank-material-shell
        ]
        ++ coreModules
        ++ [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            imports = homeModules;
            home-manager.users = userConfigs;
          }
        ];
    };
  };
}
