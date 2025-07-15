{ lib, pkgs, ... }:

{
  just-deprecated-enable = ./deprecated-enable.nix;
  just-deprecated-bash-integration = ./deprecated-bash-integration.nix;
  just-deprecated-zsh-integration = ./deprecated-zsh-integration.nix;
  just-deprecated-fish-integration = ./deprecated-fish-integration.nix;
}
