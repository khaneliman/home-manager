{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  sctd-basic-configuration = ./basic-configuration.nix;
  sctd-with-custom-temperature = ./with-custom-temperature.nix;
}
