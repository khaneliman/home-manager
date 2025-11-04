{ config, ... }:

{
  config = {
    programs.obs-studio = {
      enable = true;
    };

    test.stubs = {
      obs-studio = { };
    };

    nmt.script = ''
      # Test that obs-studio is enabled
      # The finalPackage should be generated from wrapping obs-studio
      finalPackage=${config.programs.obs-studio.finalPackage}
      if [[ -z "$finalPackage" ]]; then
        fail "Expected obs-studio.finalPackage to be set"
      fi

      # Test that the finalPackage is installed in home.packages
      assertFileExists home-path/bin/dummy
    '';
  };
}
