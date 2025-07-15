{ config, ... }:

{
  config = {
    services.mbsync = {
      enable = true;
      frequency = "*:0/10";
      verbose = false;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/mbsync.service \
        ${./custom-frequency-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/mbsync.timer \
        ${./custom-frequency-expected.timer}
    '';
  };
}
