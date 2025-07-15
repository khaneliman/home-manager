{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  stalonetray-basic-configuration = ./basic-configuration.nix;
  stalonetray-with-config = ./with-config.nix;
  stalonetray-with-extra-config = ./with-extra-config.nix;
}
