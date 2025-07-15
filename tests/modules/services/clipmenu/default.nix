{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  clipmenu-basic-configuration = ./basic-configuration.nix;
  clipmenu-custom-launcher = ./custom-launcher.nix;
}
