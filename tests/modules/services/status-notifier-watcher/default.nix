{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  status-notifier-watcher-basic-service = ./basic-service.nix;
}
