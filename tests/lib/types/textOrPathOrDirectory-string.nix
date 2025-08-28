{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) hm mkOption;
in
{
  options.testConfig = mkOption {
    type = hm.types.textOrPathOrDirectory;
    description = "Test config using textOrPathOrDirectory with string";
  };

  config = {
    testConfig = ''
      # Default configuration content
      theme = "dark"
      language = "en"

      [advanced]
      cache_size = 1000
    '';

    home.file."myapp/config.conf" = hm.types.textOrPathOrDirectoryToHomeFile config.testConfig;

    nmt.script = ''
      assertFileExists home-files/myapp/config.conf
      assertFileContent home-files/myapp/config.conf ${pkgs.writeText "expected-content" ''
        # Default configuration content
        theme = "dark"
        language = "en"

        [advanced]
        cache_size = 1000
      ''}
    '';
  };
}
