{ config, ... }:

{
  config = {
    programs.havoc = {
      enable = true;
      settings = {
        child.program = "bash";
        window = {
          opacity = 240;
          margin = "no";
        };
        terminal = {
          rows = 80;
          columns = 24;
          scrollback = 2000;
        };
        bind = {
          "C-S-c" = "copy";
          "C-S-v" = "paste";
          "C-S-r" = "reset";
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/havoc.cfg
      assertFileContent \
        home-files/.config/havoc.cfg \
        ${./with-settings-expected.cfg}
    '';
  };
}
