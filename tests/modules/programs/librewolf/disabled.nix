{ config, ... }:

{
  config = {
    programs.librewolf = {
      enable = false;
      settings = {
        "webgl.disabled" = false;
        "privacy.resistFingerprinting" = false;
      };
    };

    nmt.script = ''
      # Test that no LibreWolf package is installed when disabled
      assertPathNotExists home-path/bin/librewolf

      # Test that no settings file is created when disabled
      assertPathNotExists home-files/.librewolf/librewolf.overrides.cfg
    '';
  };
}
