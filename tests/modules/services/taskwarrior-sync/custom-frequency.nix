{ config, ... }:

{
  config = {
    services.taskwarrior-sync = {
      enable = true;
      frequency = "hourly";
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.service \
        ${./custom-frequency-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.timer \
        ${./custom-frequency-expected.timer}
    '';
  };
}
