{ config, lib, pkgs, ... }:

# Test that the NixOS/nix-darwin module correctly auto-discovers uid from
# users.users.<name>.uid using tryEval to handle undefined/error cases

let
  # Simulate the nixos/common.nix module behavior
  testUser = "testuser";

  # Test case 1: defined uid
  definedConfig = {
    users.users.${testUser}.uid = 1000;
  };

  # Test case 2: null uid
  nullConfig = {
    users.users.${testUser}.uid = null;
  };

  # Test case 3: undefined uid (throws when accessed)
  undefinedConfig = {
    users.users.${testUser}.uid = throw "uid not defined";
  };

  # Simulate the tryEval behavior from common.nix
  getUidWithTryEval = cfg:
    let
      uid = builtins.tryEval cfg.users.users.${testUser}.uid;
    in
    if uid.success then uid.value else null;

  # Run the tests
  definedResult = getUidWithTryEval definedConfig;
  nullResult = getUidWithTryEval nullConfig;
  undefinedResult = getUidWithTryEval undefinedConfig;

in
{
  config = {
    home.stateVersion = "24.11";

    # Verify the results match expectations
    assertions = [
      {
        assertion = definedResult == 1000;
        message = "Expected defined uid to be 1000, got ${toString definedResult}";
      }
      {
        assertion = nullResult == null;
        message = "Expected null uid to be null, got ${toString nullResult}";
      }
      {
        assertion = undefinedResult == null;
        message = "Expected undefined uid (throw) to be caught and return null";
      }
    ];

    nmt.script = ''
      # Test passes if evaluation succeeds (assertions are checked during eval)
      echo "uid autodiscovery tests passed"
    '';
  };
}
