{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  psd-basic-configuration = ./basic-configuration.nix;
  psd-with-settings = ./with-settings.nix;
}
