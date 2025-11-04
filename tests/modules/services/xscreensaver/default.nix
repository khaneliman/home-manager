{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  xscreensaver-basic-service = ./basic-service.nix;
  xscreensaver-with-settings = ./with-settings.nix;
}
