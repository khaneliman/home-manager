{ config, ... }:

{
  config = {
    programs.tint2 = {
      enable = true;
      package = config.lib.test.mkStubPackage { };
      extraConfig = ''
        panel_items = T
        panel_size = 100% 30
      '';
    };

    nmt.script = ''
      assertFileExists home-path/.config/tint2/tint2rc
      assertFileContains home-path/.config/tint2/tint2rc "panel_items = T"
    '';
  };
}
