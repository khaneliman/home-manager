{ config, ... }:

{
  config = {
    services.vdirsyncer = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.service \
        ${./basic-service-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/vdirsyncer.timer \
        ${./basic-service-expected.timer}
    '';
  };
}
