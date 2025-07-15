{ config, ... }:

{
  config = {
    services.autorandr = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/autorandr.service \
        ${./basic-service-expected.service}
    '';
  };
}
