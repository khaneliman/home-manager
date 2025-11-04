{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  plex-mpv-shim-basic-configuration = ./basic-configuration.nix;
  plex-mpv-shim-with-settings = ./with-settings.nix;
}
