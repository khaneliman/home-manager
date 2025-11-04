{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  owncloud-client-basic-configuration = ./basic-configuration.nix;
}
