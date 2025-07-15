{ config, ... }:

{
  config = {
    services.tahoe-lafs = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/tahoe-lafs.service \
        ${./basic-service-expected.service}
    '';
  };
}
