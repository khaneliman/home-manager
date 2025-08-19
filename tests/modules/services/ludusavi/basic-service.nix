{ config, ... }:

{
  config = {
    services.ludusavi = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/ludusavi.service \
        ${./basic-service-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/ludusavi.timer \
        ${./basic-service-expected.timer}

      assertFileContent \
        home-files/.config/ludusavi/config.yaml \
        ${./basic-config-expected.yaml}
    '';
  };
}