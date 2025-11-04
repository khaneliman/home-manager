{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  keynav-basic-configuration = ./basic-configuration.nix;
}
