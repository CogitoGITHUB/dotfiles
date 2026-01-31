{ lib, ... }:

let
  nixFilesRecursive = dir:
    builtins.concatMap (name:
      let
        path = "${dir}/${name}";
        isDir = builtins.tryEval (builtins.readDir path).success;
      in if isDir then
        nixFilesRecursive path
      else if lib.hasSuffix ".nix" path && !(lib.hasInfix "/_" path) then
        [ path ]
      else
        []
    ) (builtins.attrNames (builtins.readDir dir));
in
{
  imports = nixFilesRecursive ./kernel-modules;
}
