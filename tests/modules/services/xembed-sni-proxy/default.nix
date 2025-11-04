{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  xembed-sni-proxy-basic-service = ./basic-service.nix;
}
