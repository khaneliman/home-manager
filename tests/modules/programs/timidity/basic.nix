{ config, ... }:

{
  config = {
    programs.timidity = {
      enable = true;
      package = config.lib.test.mkStubPackage { };
    };

    nmt.script = ''
      assertFileExists home-path/.nix-profile/bin/timidity
    '';
  };
}
