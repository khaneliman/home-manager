{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  poweralertd-basic-configuration = ./basic-configuration.nix;
  poweralertd-with-extra-args = ./with-extra-args.nix;
}
