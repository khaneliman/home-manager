{ config, ... }:

{
  config = {
    programs.chromium = {
      enable = true;
      package = config.lib.test.mkStubPackage {
        name = "chromium-test";
        buildScript = "mkdir -p $out/bin; echo '#!/bin/sh' > $out/bin/chromium; chmod +x $out/bin/chromium";
      };
    };

    nmt.script = ''
      # Test that chromium package is installed
      assertFileExists home-path/bin/chromium
    '';
  };
}
