{ lib, pkgs, ... }:

{
  obs-studio-enable-only = ./enable-only.nix;
  obs-studio-with-plugins = ./with-plugins.nix;
  obs-studio-null-package = ./null-package.nix;
}
