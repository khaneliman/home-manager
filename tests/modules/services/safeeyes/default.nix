{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  safeeyes-basic-service = ./basic-service.nix;
}
