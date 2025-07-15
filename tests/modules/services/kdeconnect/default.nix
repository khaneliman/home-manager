{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  kdeconnect-basic-service = ./basic-service.nix;
  kdeconnect-indicator-service = ./indicator-service.nix;
}
