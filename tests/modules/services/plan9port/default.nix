{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  plan9port-fontsrv = ./fontsrv.nix;
  plan9port-plumber = ./plumber.nix;
  plan9port-both-enabled = ./both-enabled.nix;
}
