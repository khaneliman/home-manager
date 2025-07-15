{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  havoc-basic-configuration = ./basic-configuration.nix;
  havoc-with-settings = ./with-settings.nix;
  havoc-package-null = ./package-null.nix;
}
