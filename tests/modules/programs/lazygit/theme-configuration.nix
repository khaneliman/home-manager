{ config, ... }:

{
  config = {
    programs.lazygit = {
      enable = true;
      settings = {
        gui.theme = {
          lightTheme = true;
          activeBorderColor = [
            "blue"
            "bold"
          ];
          inactiveBorderColor = [ "black" ];
          selectedLineBgColor = [ "default" ];
        };
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/lazygit/config.yml \
        ${./theme-configuration-expected.yml}
    '';
  };
}
