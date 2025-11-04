{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  amberol-custom-settings = ./custom-settings.nix;
}
