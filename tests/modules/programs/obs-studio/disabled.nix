{ config, ... }:

{
  config = {
    programs.obs-studio = {
      enable = false;
      plugins = [
        (config.lib.test.mkStubPackage {
          name = "obs-studio-plugins.wlrobs";
          version = "1.0.0";
        })
      ];
    };

    nmt.script = ''
      # Test that no obs-studio package is installed when disabled
      assertPathNotExists home-path/bin/dummy
    '';
  };
}
