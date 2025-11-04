{ config, ... }:

{
  config = {
    programs.librewolf = {
      enable = true;
      settings = { };
    };

    test.stubs.librewolf = { };

    nmt.script = ''
      # Test that LibreWolf package is installed
      assertFileExists home-path/bin/librewolf

      # Test that no settings file is created when settings are empty
      assertPathNotExists home-files/.librewolf/librewolf.overrides.cfg
    '';
  };
}
