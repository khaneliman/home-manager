{ lib, pkgs, ... }:

{
  noti-enable-only = ./enable-only.nix;
  noti-with-settings = ./with-settings.nix;
  noti-null-package = ./null-package.nix;
}
