{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  xidlehook-basic-service = ./basic-service.nix;
  xidlehook-with-options = ./with-options.nix;
  xidlehook-with-timers = ./with-timers.nix;
}
