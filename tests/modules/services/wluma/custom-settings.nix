{
  config = {
    services.wluma = {
      enable = true;
      settings = {
        als.iio = {
          path = "/sys/bus/iio/devices/iio:device0";
          thresholds = {
            "0" = "night";
            "20" = "dark";
            "80" = "dim";
            "250" = "normal";
            "500" = "bright";
            "800" = "outdoors";
          };
        };
      };
    };

    nmt.script = ''
      assertFileContent \
        $(normalizeStorePaths home-files/.config/systemd/user/wluma.service) \
        ${./custom-settings-expected.service}

      assertFileExists home-files/.config/wluma/config.toml
      assertFileContent \
        home-files/.config/wluma/config.toml \
        ${./custom-settings-expected.toml}
    '';
  };
}
