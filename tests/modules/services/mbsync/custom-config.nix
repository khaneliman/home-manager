{ config, ... }:

{
  config = {
    services.mbsync = {
      enable = true;
      configFile = "/home/user/.config/mbsync/config";
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/mbsync.service
      assertFileContent \
        home-files/.config/systemd/user/mbsync.service \
        ${./custom-config-expected.service}
    '';
  };
}
