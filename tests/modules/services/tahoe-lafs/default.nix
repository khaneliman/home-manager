{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  tahoe-lafs-basic-service = ./basic-service.nix;
}
