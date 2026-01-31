{ lib, ... }:

let
  coreModulesDir = ./core-modules;
  corePackagesDir = ./core-packages;

  # Recursively list .nix files
  nixFilesRecursive = dir:
    let
      entries = builtins.attrNames (builtins.readDir dir);
    in
      lib.concatMap (name:
        let path = "${dir}/${name}";
            # safe directory check
            tryDir = builtins.tryEval (builtins.readDir path);
            isDir = tryDir.success && lib.isAttrs tryDir.value;
        in if isDir then
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
