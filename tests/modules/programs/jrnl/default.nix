{ lib, pkgs, ... }:

{
  jrnl-enable-only = ./enable-only.nix;
  jrnl-with-settings = ./with-settings.nix;
  jrnl-null-package = ./null-package.nix;
}
