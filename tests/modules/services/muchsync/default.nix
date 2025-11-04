{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  muchsync-basic-configuration = ./basic-configuration.nix;
}
