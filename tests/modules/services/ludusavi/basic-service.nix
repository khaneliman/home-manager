{ config, ... }:

{
  config = {
    services.ludusavi = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/ludusavi.service
      assertFileContent \
        home-files/.config/systemd/user/ludusavi.service \
        ${./basic-service-expected.service}

      assertFileExists home-files/.config/systemd/user/ludusavi.timer
      assertFileContent \
        home-files/.config/systemd/user/ludusavi.timer \
        ${./basic-service-expected.timer}

      assertFileExists home-files/.config/ludusavi/config.yaml
      assertFileContent \
        home-files/.config/ludusavi/config.yaml \
        ${./basic-config-expected.yaml}
    '';
  };
}
