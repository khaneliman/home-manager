{ config, ... }:

{
  config = {
    services.systembus-notify = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/systembus-notify.service \
        ${./basic-service-expected.service}
    '';
  };
}
