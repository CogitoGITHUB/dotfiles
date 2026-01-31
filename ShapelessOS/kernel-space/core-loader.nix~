# kernel-space/core/core-loader.nix
{ lib, ... }:
let
  # Directories
  coreModulesDir = ./core-modules;
  corePackagesDir = ./core-packages;
  
  # Read and filter .nix files
  nixFiles = dir: 
    lib.filter (name: lib.hasSuffix ".nix" name)
      (builtins.attrNames (builtins.readDir dir));
  
  # Generate full paths
  coreModules = map (f: "${coreModulesDir}/${f}") (nixFiles coreModulesDir);
  corePackages = map (f: "${corePackagesDir}/${f}") (nixFiles corePackagesDir);
in
{
  # Import everything automatically
  imports = coreModules ++ corePackages;
}
