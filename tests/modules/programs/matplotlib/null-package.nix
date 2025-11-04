{
  config = {
    programs.matplotlib = {
      enable = true;
      package = null;
      config = {
        backend = "Agg";
      };
    };

    nmt.script = ''
      # Config files should still be created
      assertFileExists home-files/.config/matplotlib/matplotlibrc

      # But package should not be installed
      assertPathNotExists home-path/bin/matplotlib
    '';
  };
}
