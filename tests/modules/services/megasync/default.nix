{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  megasync-basic-configuration = ./basic-configuration.nix;
  megasync-force-wayland = ./force-wayland.nix;
}
