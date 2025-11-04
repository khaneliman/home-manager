{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  hound-basic-configuration = ./basic-configuration.nix;
  hound-with-repositories = ./with-repositories.nix;
}
