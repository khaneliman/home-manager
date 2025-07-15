{ lib, pkgs, ... }:

{
  librewolf-enable-only = ./enable-only.nix;
  librewolf-with-settings = ./with-settings.nix;
  librewolf-with-profiles = ./with-profiles.nix;
}
