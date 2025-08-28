{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) hm mkOption;

  # Create a mock directory structure for testing
  testConfigDir = pkgs.runCommand "test-config-dir" { } ''
        mkdir -p $out/subdir
        cat > $out/main.conf <<EOF
    # Main configuration
    theme = dark
    debug = true
    EOF

        cat > $out/subdir/extra.conf <<EOF
    # Extra configuration
    timeout = 30
    retries = 5
    EOF
  '';
in
{
  options.testConfig = mkOption {
    type = hm.types.textOrPathOrDirectory;
    description = "Test config using textOrPathOrDirectory with directory spec";
  };

  config = {
    testConfig = {
      source = testConfigDir;
      recursive = true;
    };

    home.file."myapp" = hm.types.textOrPathOrDirectoryToHomeFile config.testConfig;

    nmt.script = ''
      # Verify directory was linked with recursive structure
      assertDirectoryExists home-files/myapp
      assertFileExists home-files/myapp/main.conf
      assertFileExists home-files/myapp/subdir/extra.conf
    '';
  };
}
