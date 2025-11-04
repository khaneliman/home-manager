{ config, ... }:

{
  config = {
    services.autorandr = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/autorandr.service
      assertFileContent \
        home-files/.config/systemd/user/autorandr.service \
        ${./basic-service-expected.service}
    '';
  };
}
