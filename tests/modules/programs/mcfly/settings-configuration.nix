{ config, ... }:

{
  config = {
    programs.mcfly = {
      enable = true;
      settings = {
        colors = {
          menubar = {
            bg = "black";
            fg = "red";
          };
          darkmode = {
            prompt = "cyan";
            timing = "yellow";
            results_selection_fg = "cyan";
            results_selection_bg = "black";
            results_selection_hl = "red";
          };
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.local/share/mcfly/config.toml
      assertFileContent \
        home-files/.local/share/mcfly/config.toml \
        ${./settings-configuration-expected.toml}
    '';
  };
}
