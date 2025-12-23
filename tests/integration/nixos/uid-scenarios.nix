{ lib, ... }:

{
  name = "nixos-uid-scenarios";
  meta.maintainers = [ lib.maintainers.khaneliman ];

  nodes.machine = {
    imports = [ ../../../nixos ]; # Import the HM NixOS module.

    virtualisation.memorySize = 2048;

    users.users = {
      # Test user with explicit uid - should use that value
      defined = {
        isNormalUser = true;
        password = "foobar";
        uid = 1000;
      };

      # Test user without explicit uid - should handle gracefully
      # Simulate nix-darwin where accessing undefined uid throws an error
      undefined = {
        isNormalUser = true;
        password = "foobar";
      };

      # Test user with null uid - should handle gracefully
      null = {
        isNormalUser = true;
        password = "foobar";
        uid = null;
      };
    };

    home-manager.users = {
      defined = {
        home.stateVersion = "24.11";
        home.file.test.text = "defined";
      };

      undefined = {
        home.stateVersion = "24.11";
        home.file.test.text = "undefined";
      };

      null = {
        home.stateVersion = "24.11";
        home.file.test.text = "null";
      };
    };
  };

  testScript = ''
    start_all()

    # All users should activate successfully despite different uid scenarios
    machine.wait_for_console_text("Finished Home Manager environment for defined.")
    machine.wait_for_console_text("Finished Home Manager environment for undefined.")
    machine.wait_for_console_text("Finished Home Manager environment for null.")

    # Verify files were created for all users
    machine.succeed("test -L /home/defined/test")
    machine.succeed("test -L /home/undefined/test")
    machine.succeed("test -L /home/null/test")

    # Verify defined got the explicit uid
    defined_uid = machine.succeed("id -u defined").strip()
    assert defined_uid == "1000", f"expected defined uid to be 1000, got {defined_uid}"

    # undefined and null should have system-assigned uids (not null, not error)
    undefined_uid = machine.succeed("id -u undefined").strip()
    assert undefined_uid.isdigit(), f"expected undefined to have a numeric uid, got {undefined_uid}"

    null_uid = machine.succeed("id -u null").strip()
    assert null_uid.isdigit(), f"expected null to have a numeric uid, got {null_uid}"
  '';
}
