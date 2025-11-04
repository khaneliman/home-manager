{ config, ... }:

{
  config = {
    services.vdirsyncer = {
      enable = true;
      configFile = "/custom/path/vdirsyncer-config";
      verbosity = "INFO";
      frequency = "daily";
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/vdirsyncer.service
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.service \
        ${./custom-config-expected.service}

      assertFileExists home-files/.config/systemd/user/vdirsyncer.timer
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.timer \
        ${./custom-config-expected.timer}
    '';
  };
}
