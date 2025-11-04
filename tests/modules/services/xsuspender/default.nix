{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  xsuspender-basic-service = ./basic-service.nix;
  xsuspender-with-rules = ./with-rules.nix;
  xsuspender-with-defaults = ./with-defaults.nix;
}
