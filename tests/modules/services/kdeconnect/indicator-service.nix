{ config, ... }:

{
  config = {
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/kdeconnect.service
      assertFileContent \
        home-files/.config/systemd/user/kdeconnect.service \
        ${./basic-service-expected.service}

      assertFileExists home-files/.config/systemd/user/kdeconnect-indicator.service
      assertFileContent \
        home-files/.config/systemd/user/kdeconnect-indicator.service \
        ${./indicator-service-expected.service}
    '';
  };
}
