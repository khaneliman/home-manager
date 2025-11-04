{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  cbatticon-basic-configuration = ./basic-configuration.nix;
  cbatticon-with-all-options = ./with-all-options.nix;
}
