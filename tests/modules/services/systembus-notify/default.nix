{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  systembus-notify-basic-service = ./basic-service.nix;
}
