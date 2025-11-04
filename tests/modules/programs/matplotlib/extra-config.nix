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
        backend = "Agg";
        figure.dpi = 100;
      };
      extraConfig = ''
        # Custom matplotlib configuration
        lines.linewidth: 2.0
        markers.fillstyle: full
      '';
    };

    nmt.script = ''
      assertFileExists home-files/.config/matplotlib/matplotlibrc
      assertFileContent \
        home-files/.config/matplotlib/matplotlibrc \
        ${./extra-config-expected.txt}
    '';
  };
}
