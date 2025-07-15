{ config, ... }:

{
  config = {
    programs.navi = {
      enable = true;
      settings = {
        cheats = {
          paths = [
            "~/cheats/"
            "~/.local/share/navi/cheats/"
          ];
        };
        finder = {
          command = "fzf";
        };
        shell = {
          command = "bash";
        };
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/navi/config.yaml \
        ${./settings-configuration-expected.yaml}
    '';
  };
}
