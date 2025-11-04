{ lib, pkgs, ... }:
lib.optionalAttrs pkgs.stdenv.isLinux {
  quickshell-basic = ./basic.nix;
  quickshell-with-configs = ./with-configs.nix;
  quickshell-with-systemd = ./with-systemd.nix;
  quickshell-null-package = ./null-package.nix;
}
