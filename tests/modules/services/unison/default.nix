{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  unison-basic-pair = ./basic-pair.nix;
  unison-custom-options = ./custom-options.nix;
  unison-null-package = ./null-package.nix;
}
