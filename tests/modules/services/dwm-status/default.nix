{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  dwm-status-basic-configuration = ./basic-configuration.nix;
  dwm-status-with-extra-config = ./with-extra-config.nix;
}
