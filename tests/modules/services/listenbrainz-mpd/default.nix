{ lib, pkgs, ... }:

{
  listenbrainz-mpd-basic-configuration = ./basic-configuration.nix;
  listenbrainz-mpd-with-settings = ./with-settings.nix;
}
