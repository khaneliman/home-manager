{ config, ... }:

{
  config = {
    services.vdirsyncer = {
      enable = true;
      frequency = "hourly";
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.service \
        ${./custom-frequency-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.timer \
        ${./custom-frequency-expected.timer}
    '';
  };
}
