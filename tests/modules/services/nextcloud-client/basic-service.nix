{ config, ... }:

{
  config = {
    services.nextcloud-client = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/nextcloud-client.service
      assertFileContent \
        home-files/.config/systemd/user/nextcloud-client.service \
        ${./basic-service-expected.service}
    '';
  };
}
