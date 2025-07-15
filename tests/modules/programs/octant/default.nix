{ lib, pkgs, ... }:

{
  octant-enable-only = ./enable-only.nix;
  octant-with-plugins = ./with-plugins.nix;
}
