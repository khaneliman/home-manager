{ lib, pkgs, ... }:
lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  eclipse-basic-configuration = ./basic-configuration.nix;
}
