{ lib, ... }:

let
  coreModulesDir = ./core-modules;
  corePackagesDir = ./core-packages;

  # Recursively list .nix files in a directory and all subdirs
  nixFilesRecursive = dir:
    let
      entries = builtins.attrNames (builtins.readDir dir);
    in
      lib.concatMap (name:
        let path = "${dir}/${name}";
        in if builtins.isDirectory path then
             nixFilesRecursive path
           else if lib.hasSuffix ".nix" name then
             [ path ]
           else
             []
      ) entries;

  coreModules = nixFilesRecursive coreModulesDir;
  corePackages = nixFilesRecursive corePackagesDir;

in
{
  imports = coreModules ++ corePackages;
}
