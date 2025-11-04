{ lib, pkgs, ... }:

{
  opam-enable-only = ./enable-only.nix;
  opam-shell-integration = ./shell-integration.nix;
  opam-null-package = ./null-package.nix;
  opam-disabled-integration = ./disabled-integration.nix;
}
