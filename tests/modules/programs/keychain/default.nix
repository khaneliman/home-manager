{ lib, pkgs, ... }:

{
  keychain-enable-only = ./enable-only.nix;
  keychain-with-options = ./with-options.nix;
  keychain-shell-integration = ./shell-integration.nix;
  keychain-deprecated-agents = ./deprecated-agents.nix;
  keychain-deprecated-inherit = ./deprecated-inherit.nix;
}
