{ lib, pkgs, ... }:

lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
  batsignal-basic-service = ./basic-service.nix;
  batsignal-custom-args = ./custom-args.nix;
}
