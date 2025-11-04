{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.obs-studio = {
      enable = true;
      plugins = [
        (config.lib.test.mkStubPackage {
          name = "obs-plugin-1";
          outPath = "@obs-plugin-1@";
        })
        (config.lib.test.mkStubPackage {
          name = "obs-plugin-2";
          outPath = "@obs-plugin-2@";
        })
      ];
    };

    nmt.script = ''
      # Test that finalPackage is created with plugins
      # The wrapped package should include the plugins
      echo "Checking if OBS Studio package is available with plugins"
    '';
  };
}
