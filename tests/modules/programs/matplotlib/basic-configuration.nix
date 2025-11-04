{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.matplotlib = {
      enable = true;
      config = {
        backend = "Qt5Agg";
        figure.figsize = "8, 6";
        font.size = 12;
        interactive = true;
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/matplotlib/matplotlibrc
      assertFileContent \
        home-files/.config/matplotlib/matplotlibrc \
        ${./basic-configuration-expected.txt}
    '';
  };
}
