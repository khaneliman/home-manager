{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  pulseeffects-basic-configuration = ./basic-configuration.nix;
  pulseeffects-with-preset = ./with-preset.nix;
}
