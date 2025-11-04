{ config, ... }:

{
  config = {
    services.mbsync = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/mbsync.service
      assertFileContent \
        home-files/.config/systemd/user/mbsync.service \
        ${./basic-service-expected.service}

      assertFileExists home-files/.config/systemd/user/mbsync.timer
      assertFileContent \
        home-files/.config/systemd/user/mbsync.timer \
        ${./basic-service-expected.timer}
    '';
  };
}
