{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  rsibreak-basic-service = ./basic-service.nix;
}
