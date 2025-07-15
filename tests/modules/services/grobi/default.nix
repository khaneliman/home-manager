{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  grobi-basic-configuration = ./basic-configuration.nix;
  grobi-with-rules = ./with-rules.nix;
  grobi-with-execute-after = ./with-execute-after.nix;
}
