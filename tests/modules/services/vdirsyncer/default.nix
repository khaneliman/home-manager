{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  vdirsyncer-basic-service = ./basic-service.nix;
  vdirsyncer-custom-frequency = ./custom-frequency.nix;
  vdirsyncer-verbosity-options = ./verbosity-options.nix;
  vdirsyncer-custom-config = ./custom-config.nix;
}
