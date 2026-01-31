{ lib, ... }:

{
  imports =
    builtins.filter (path:
      lib.hasSuffix ".nix" path
      && !(lib.hasInfix "/_" path)  # ignore files/dirs starting with _
    ) (lib.fileset.toList ./kernel-modules);
}