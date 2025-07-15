{ lib, pkgs, ... }:

{
  obsidian-enable-only = ./enable-only.nix;
  obsidian-with-vault = ./with-vault.nix;
  obsidian-with-defaults = ./with-defaults.nix;
}
