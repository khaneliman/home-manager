{ lib, pkgs, ... }:
lib.optionalAttrs pkgs.stdenv.isLinux {
  waylogout-basic = ./basic.nix;
  waylogout-null-package = ./null-package.nix;
}
