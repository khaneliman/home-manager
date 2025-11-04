{ config, ... }:

{
  config = {
    services.unclutter = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/unclutter.service
      assertFileContent \
        home-files/.config/systemd/user/unclutter.service \
        ${./basic-service-expected.service}
    '';
  };
}
