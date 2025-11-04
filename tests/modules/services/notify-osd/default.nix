{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  notify-osd-basic-configuration = ./basic-configuration.nix;
}
