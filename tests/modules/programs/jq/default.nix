{ lib, pkgs, ... }:

{
  jq-enable-only = ./enable-only.nix;
  jq-with-colors = ./with-colors.nix;
  jq-null-package = ./null-package.nix;
}
