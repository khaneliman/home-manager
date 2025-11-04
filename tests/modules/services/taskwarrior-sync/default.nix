{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  taskwarrior-sync-basic-service = ./basic-service.nix;
  taskwarrior-sync-custom-frequency = ./custom-frequency.nix;
  taskwarrior-sync-custom-package = ./custom-package.nix;
}
