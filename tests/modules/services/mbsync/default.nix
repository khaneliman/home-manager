{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  mbsync-basic-service = ./basic-service.nix;
  mbsync-custom-frequency = ./custom-frequency.nix;
  mbsync-with-hooks = ./with-hooks.nix;
  mbsync-custom-config = ./custom-config.nix;
}
