{ lib, pkgs, ... }:
lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  beets-basic-configuration = ./basic-configuration.nix;
  beets-mpdstats = ./mpdstats.nix;
  beets-mpdstats-external = ./mpdstats-external.nix;
  beets-mpdupdate = ./mpdupdate.nix;
}
