{ lib, ... }:

let
  modulesFrom = dir:
    lib.fileset.toList
      (path: lib.hasSuffix ".nix" path && !(lib.hasInfix "/_" path))
      { root = dir; };

  coreModules = modulesFrom ./core-modules;
  corePackages = modulesFrom ./core-packages;
in
{
  imports = coreModules ++ corePackages;
}
