{ lib, pkgs, ... }:

{
  opam-enable-only = ./enable-only.nix;
  opam-shell-integration = ./shell-integration.nix;
  opam-disabled-integration = ./disabled-integration.nix;
}