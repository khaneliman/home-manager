{ lib, pkgs, ... }:

{
  joshuto-enable-only = ./enable-only.nix;
  joshuto-with-settings = ./with-settings.nix;
}
