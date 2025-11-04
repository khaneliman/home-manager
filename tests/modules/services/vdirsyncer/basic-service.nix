{ config, ... }:

{
  config = {
    services.vdirsyncer = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/vdirsyncer.service
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.service \
        ${./basic-service-expected.service}

      assertFileExists home-files/.config/systemd/user/vdirsyncer.timer
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.timer \
        ${./basic-service-expected.timer}
    '';
  };
}
