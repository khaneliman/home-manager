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
    description = "Test config using textOrFile with path content";
  };

  config = {
    testConfig = ./default.nix;

    home.file."test-config.nix" = hm.types.textOrFileToHomeFile config.testConfig;

    nmt.script = ''
      assertFileExists home-files/test-config.nix
      assertFileRegex home-files/test-config.nix 'lib-types'
    '';
  };
}
