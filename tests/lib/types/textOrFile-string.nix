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
    type = hm.types.textOrFile;
    description = "Test config using textOrFile with string content";
  };

  config = {
    testConfig = ''
      # Test configuration file
      key1 = value1
      key2 = value2

      [section]
      option = enabled
    '';

    # Test multiple file assignments using the simplified helper
    home.file = {
      "test-config.conf" = hm.types.textOrFileToHomeFile config.testConfig;
      "another-config.txt" = {
        text = "Direct assignment works too";
      };
      "third-config.ini" = hm.types.textOrFileToHomeFile "theme=dark\nmode=advanced";
    };

    nmt.script = ''
      # Test all three files were created
      assertFileExists home-files/test-config.conf
      assertFileExists home-files/another-config.txt
      assertFileExists home-files/third-config.ini

      # Verify content of first file
      assertFileContent home-files/test-config.conf ${pkgs.writeText "expected-content" ''
        # Test configuration file
        key1 = value1
        key2 = value2

        [section]
        option = enabled
      ''}

      # Verify content of other files
      assertFileContent home-files/another-config.txt ${pkgs.writeText "expected-direct" "Direct assignment works too"}
      assertFileContent home-files/third-config.ini ${pkgs.writeText "expected-third" "theme=dark\nmode=advanced"}
    '';
  };
}
