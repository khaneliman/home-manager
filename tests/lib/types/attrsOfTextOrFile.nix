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
  options.testConfigs = mkOption {
    type = hm.types.attrsOfTextOrFile;
    description = "Test multiple configs using attrsOfTextOrFile";
  };

  config = {
    # Test attrsOfTextOrFile with mixed content
    testConfigs = {
      main = ''
        # Main configuration
        enabled = true
        debug = false
      '';

      secondary = ./default.nix;

      extra = ''
        # Extra settings
        timeout = 30
        retries = 3
      '';
    };

    # Test multiple directory assignments with different apps
    home.file =
      (hm.types.attrsOfTextOrFileToHomeFiles "myapp" config.testConfigs)
      // (hm.types.attrsOfTextOrFileToHomeFiles "anotherapp" {
        config = "port=8080\nhost=localhost";
        readme = ./default.nix;
      })
      // (hm.types.attrsOfTextOrFileToHomeFiles "thirdapp" {
        settings = ''
          [database]
          url = sqlite:///app.db
          pool_size = 10
        '';
      });

    nmt.script = ''
      # Verify myapp files
      assertFileExists home-files/myapp/main
      assertFileExists home-files/myapp/secondary
      assertFileExists home-files/myapp/extra

      # Verify anotherapp files
      assertFileExists home-files/anotherapp/config
      assertFileExists home-files/anotherapp/readme

      # Verify thirdapp files
      assertFileExists home-files/thirdapp/settings

      # Check content verification for select files
      assertFileContent home-files/myapp/main ${pkgs.writeText "main-expected" ''
        # Main configuration
        enabled = true
        debug = false
      ''}

      assertFileContent home-files/anotherapp/config ${pkgs.writeText "another-expected" "port=8080\nhost=localhost"}

      assertFileContent home-files/thirdapp/settings ${pkgs.writeText "third-expected" ''
        [database]
        url = sqlite:///app.db
        pool_size = 10
      ''}

      # Check that path files are linked correctly
      assertFileRegex home-files/myapp/secondary 'lib-types'
      assertFileRegex home-files/anotherapp/readme 'lib-types'
    '';
  };
}
