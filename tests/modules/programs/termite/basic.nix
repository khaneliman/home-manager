{ config, ... }:

{
  config = {
    programs.termite = {
      enable = true;
      package = config.lib.test.mkStubPackage { };
    };

    nmt.script = ''
      assertFileExists home-path/.config/termite/config
    '';
  };
}
