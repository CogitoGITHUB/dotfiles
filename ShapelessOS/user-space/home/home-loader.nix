# user-space/home/home-loader.nix
{ lib, ... }:
let
  # Directories
  homeModulesDir = ./home-modules;
  usersDir = ./users;
  
  # Read and filter .nix files
  nixFiles = dir: 
    lib.filter (name: lib.hasSuffix ".nix" name)
      (builtins.attrNames (builtins.readDir dir));
  
  # Generate full paths
  homeModules = map (f: "${homeModulesDir}/${f}") (nixFiles homeModulesDir);
  
  # For users, we return them as an attrset instead of importing
  # because home-manager.users expects { username = config; }
  userFiles = nixFiles usersDir;
  
  # Create user configurations mapping
  userConfigs = builtins.listToAttrs (
    map (filename: {
      name = lib.removeSuffix ".nix" filename;  # aoeu.nix -> aoeu
      value = import "${usersDir}/${filename}";
    }) userFiles
  );
in
{
  # Import all home modules
  imports = homeModules;
  
  # Export user configurations to be used in flake
  home-manager.users = userConfigs;
}
