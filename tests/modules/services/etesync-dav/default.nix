{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  etesync-dav-basic-configuration = ./basic-configuration.nix;
  etesync-dav-custom-server = ./custom-server.nix;
  etesync-dav-with-settings = ./with-settings.nix;
}
