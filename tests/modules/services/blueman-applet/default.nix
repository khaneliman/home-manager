{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  blueman-applet-basic-service = ./basic-service.nix;
}
