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
    description = "Test config using textOrPathOrDirectory with path content";
  };

  config = {
    testConfig = ./default.nix;

    home.file."myapp/config.nix" = hm.types.textOrPathOrDirectoryToHomeFile config.testConfig;

    nmt.script = ''
      assertFileExists home-files/myapp/config.nix
      assertFileRegex home-files/myapp/config.nix 'lib-types'
    '';
  };
}
