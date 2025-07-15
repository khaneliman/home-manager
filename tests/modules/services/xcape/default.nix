{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  xcape-basic-service = ./basic-service.nix;
  xcape-with-options = ./with-options.nix;
}
