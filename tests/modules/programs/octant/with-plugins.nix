{ config, ... }:

{
  config = {
    programs.octant = {
      enable = true;
      plugins = [
        (config.lib.test.mkStubPackage {
          name = "starboard-octant-plugin";
          outPath = "@starboard-octant-plugin@";
          buildScript = ''
            mkdir -p $out/bin
            echo '#!/bin/bash' > $out/bin/starboard-octant-plugin
            echo 'echo "Starboard plugin"' >> $out/bin/starboard-octant-plugin
            chmod +x $out/bin/starboard-octant-plugin
          '';
        })
        (config.lib.test.mkStubPackage {
          name = "test-octant-plugin";
          outPath = "@test-octant-plugin@";
          buildScript = ''
            mkdir -p $out/bin
            echo '#!/bin/bash' > $out/bin/test-octant-plugin
            echo 'echo "Test plugin"' >> $out/bin/test-octant-plugin
            chmod +x $out/bin/test-octant-plugin
          '';
        })
      ];
    };

    nmt.script = ''
      # Test that plugins directory is created and linked
      assertFileExists home-files/.config/octant/plugins
      
      # Test that plugin symlinks are created (though they point to store paths)
      assertFileExists home-files/.config/octant/plugins/starboard-octant-plugin
      assertFileExists home-files/.config/octant/plugins/test-octant-plugin
    '';
  };
}