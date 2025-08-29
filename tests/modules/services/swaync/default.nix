{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  swaync = ./swaync.nix;
  swaync-with-style-path = ./swaync-with-style-path.nix;
}
