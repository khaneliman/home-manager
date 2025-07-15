{ config, ... }:

{
  config = {
    services.unclutter = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/unclutter.service \
        ${./basic-service-expected.service}
    '';
  };
}
