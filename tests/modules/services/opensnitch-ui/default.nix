{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  opensnitch-ui-basic-configuration = ./basic-configuration.nix;
}
