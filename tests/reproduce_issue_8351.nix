let
  pkgs = import <nixpkgs> {};

  # The NixOS module to test
  homeManagerNixosModule = import ../nixos/default.nix;
  
  # A minimal NixOS configuration evaluation
  nixosConfig = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    inherit pkgs;
    modules = [
      homeManagerNixosModule
      {
        users.users.testuser = {
          isNormalUser = true;
          # uid = 1337; # Commented out
          home = "/home/testuser";
          group = "users";
        };

        home-manager.users.testuser = { ... }: {
          home.stateVersion = "23.11";
        };
      }
    ];
  };

in
  nixosConfig.config.home-manager.users.testuser.home.uid
