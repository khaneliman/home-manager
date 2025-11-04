{ lib, pkgs, ... }:

{
  librewolf-enable-only = ./enable-only.nix;
  librewolf-with-settings = ./with-settings.nix;
  librewolf-null-package = ./null-package.nix;
  librewolf-with-profiles = ./with-profiles.nix;
}
