{ lib, ... }:

{
  imports =
    builtins.filter (path:
      lib.hasSuffix ".nix" path
      && !(lib.hasInfix "/_" path) # ignore dirs/files starting with _
    ) (lib.fileset.toList ./core-modules)
    ++ builtins.filter (path:
      lib.hasSuffix ".nix" path
      && !(lib.hasInfix "/_" path)
    ) (lib.fileset.toList ./core-packages);
}
