{ lib, pkgs, ... }:
lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  dunst-basic-service = ./systemd-service.nix;
  dunst-config-generation = ./config-generation.nix;
  dunst-icon-theme = ./icon-theme.nix;
  dunst-wayland-display = ./wayland-display.nix;
}
