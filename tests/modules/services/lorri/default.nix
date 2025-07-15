{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  lorri-basic-service = ./basic-service.nix;
  lorri-with-notifications = ./with-notifications.nix;
}
