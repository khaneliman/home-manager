{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  spotifyd-basic-service = ./basic-service.nix;
  spotifyd-custom-settings = ./custom-settings.nix;
  spotifyd-null-package = ./null-package.nix;
}
