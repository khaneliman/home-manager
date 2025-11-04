{ config, ... }:

{
  config = {
    programs.tealdeer = {
      enable = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
        };
        updates = {
          auto_update = false;
          auto_update_interval_hours = 24;
        };
        style = {
          description = {
            foreground = "white";
          };
          code = {
            foreground = "green";
          };
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/tealdeer/config.toml
      assertFileContent \
        home-files/.config/tealdeer/config.toml \
        ${./settings-configuration-expected.toml}
    '';
  };
}
