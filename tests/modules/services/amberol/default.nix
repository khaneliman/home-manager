{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  amberol-basic-service = ./basic-service.nix;
  amberol-custom-settings = ./custom-settings.nix;
}
