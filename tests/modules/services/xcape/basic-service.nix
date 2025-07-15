{ config, ... }:

{
  config = {
    services.xcape = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/xcape.service \
        ${./basic-service-expected.service}
    '';
  };
}
