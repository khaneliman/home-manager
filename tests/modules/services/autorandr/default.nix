{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  autorandr-basic-service = ./basic-service.nix;
  autorandr-custom-options = ./custom-options.nix;
  autorandr-extra-options = ./extra-options.nix;
}
