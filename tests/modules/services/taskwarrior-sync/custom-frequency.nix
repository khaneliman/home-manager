{ config, ... }:

{
  config = {
    services.taskwarrior-sync = {
      enable = true;
      frequency = "hourly";
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/taskwarrior-sync.service
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.service \
        ${./custom-frequency-expected.service}

      assertFileExists home-files/.config/systemd/user/taskwarrior-sync.timer
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.timer \
        ${./custom-frequency-expected.timer}
    '';
  };
}
