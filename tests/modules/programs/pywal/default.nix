{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.isLinux {
  pywal-basic = ./basic.nix;
}
