{ config, ... }:

{
  config = {
    services.mbsync = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/mbsync.service \
        ${./basic-service-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/mbsync.timer \
        ${./basic-service-expected.timer}
    '';
  };
}
