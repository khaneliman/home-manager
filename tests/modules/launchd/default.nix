{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
  launchd-agents = ./agents.nix;
}
