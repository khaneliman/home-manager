{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  taffybar-basic-service = ./basic-service.nix;
}
