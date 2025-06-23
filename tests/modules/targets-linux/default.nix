{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  targets-generic-linux = ./generic-linux.nix;
}
