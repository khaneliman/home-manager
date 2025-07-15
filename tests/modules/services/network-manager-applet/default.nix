{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  network-manager-applet-basic-service = ./basic-service.nix;
  network-manager-applet-with-indicator = ./with-indicator.nix;
}
