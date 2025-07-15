{ config, ... }:

{
  config = {
    services.nextcloud-client = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/nextcloud-client.service \
        ${./basic-service-expected.service}
    '';
  };
}
