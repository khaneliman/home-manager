{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  nextcloud-client-basic-service = ./basic-service.nix;
  nextcloud-client-background-service = ./background-service.nix;
}
