{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  unclutter-basic-service = ./basic-service.nix;
  unclutter-custom-options = ./custom-options.nix;
}
