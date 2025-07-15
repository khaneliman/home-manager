{ config, ... }:

{
  config = {
    programs.xplr = {
      enable = true;
      package = config.lib.test.mkStubPackage { version = "0.21.9"; };
      extraConfig = ''
        xplr.config.general.show_hidden = true
      '';
    };

    nmt.script = ''
      assertFileExists home-path/.config/xplr/init.lua
      assertFileContains home-path/.config/xplr/init.lua "version = '0.21.9'"
      assertFileContains home-path/.config/xplr/init.lua "show_hidden = true"
    '';
  };
}
