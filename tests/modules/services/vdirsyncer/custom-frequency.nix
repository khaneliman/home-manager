{ config, ... }:

{
  config = {
    services.vdirsyncer = {
      enable = true;
      frequency = "hourly";
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/vdirsyncer.service
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.service \
        ${./custom-frequency-expected.service}

      assertFileExists home-files/.config/systemd/user/vdirsyncer.timer
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.timer \
        ${./custom-frequency-expected.timer}
    '';
  };
}
