{ config, ... }:

{
  config = {
    services.xcape = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xcape.service
      assertFileContent \
        home-files/.config/systemd/user/xcape.service \
        ${./basic-service-expected.service}
    '';
  };
}
