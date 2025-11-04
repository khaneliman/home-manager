{ lib, pkgs, ... }:

{
  pueue-basic-service = ./basic-service.nix;
  pueue-custom-settings = ./custom-settings.nix;
  pueue-null-package = ./null-package.nix;
}
// lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
  pueue-darwin-launchd = ./darwin-launchd.nix;
}
