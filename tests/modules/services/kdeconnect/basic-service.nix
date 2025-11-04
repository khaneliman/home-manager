{ config, ... }:

{
  config = {
    services.kdeconnect = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/kdeconnect.service
      assertFileContent \
        home-files/.config/systemd/user/kdeconnect.service \
        ${./basic-service-expected.service}
    '';
  };
}
