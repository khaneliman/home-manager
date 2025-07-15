{ config, ... }:

{
  config = {
    programs.lazygit = {
      enable = true;
      settings = {
        git = {
          paging = {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          };
        };
        refresher = {
          refreshInterval = 10;
          fetchInterval = 60;
        };
        update = {
          method = "prompt";
        };
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/lazygit/config.yml \
        ${./yaml-settings-expected.yml}
    '';
  };
}
