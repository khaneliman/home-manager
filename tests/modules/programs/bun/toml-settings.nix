{
  config = {
    programs.bun = {
      enable = true;
      settings = {
        smol = true;
        telemetry = false;
        test = {
          coverage = true;
          coverageThreshold = 0.9;
        };
        install.lockfile = {
          print = "yarn";
        };
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/.bunfig.toml \
        ${./toml-settings-expected.toml}
    '';
  };
}
