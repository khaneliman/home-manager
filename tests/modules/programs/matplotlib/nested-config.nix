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
        axes = {
          grid = true;
          facecolor = "black";
          edgecolor = "FF9900";
        };
        grid.color = "FF9900";
        font = {
          family = "serif";
          size = 14;
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/matplotlib/matplotlibrc
      assertFileContent \
        home-files/.config/matplotlib/matplotlibrc \
        ${./nested-config-expected.txt}
    '';
  };
}
