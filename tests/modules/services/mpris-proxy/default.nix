{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  mpris-proxy-basic-configuration = ./basic-configuration.nix;
}
