{ config, ... }:

{
  config = {
    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/nextcloud-client.service \
        ${./background-service-expected.service}
    '';
  };
}
