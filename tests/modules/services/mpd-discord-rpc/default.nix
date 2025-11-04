{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  mpd-discord-rpc-basic-configuration = ./basic-configuration.nix;
  mpd-discord-rpc-with-settings = ./with-settings.nix;
}
