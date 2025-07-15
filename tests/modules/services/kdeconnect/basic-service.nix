{ config, ... }:

{
  config = {
    services.kdeconnect = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/kdeconnect.service \
        ${./basic-service-expected.service}
    '';
  };
}
