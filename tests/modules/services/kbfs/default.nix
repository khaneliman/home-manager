{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  kbfs-basic-configuration = ./basic-configuration.nix;
  kbfs-with-options = ./with-options.nix;
}
