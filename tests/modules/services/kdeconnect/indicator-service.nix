{ config, ... }:

{
  config = {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/kdeconnect.service \
        ${./basic-service-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/kdeconnect-indicator.service \
        ${./indicator-service-expected.service}
    '';
  };
}
