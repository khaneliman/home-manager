{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  betterlockscreen-basic-configuration = ./basic-configuration.nix;
  betterlockscreen-with-arguments = ./with-arguments.nix;
  betterlockscreen-custom-interval = ./custom-interval.nix;
}
