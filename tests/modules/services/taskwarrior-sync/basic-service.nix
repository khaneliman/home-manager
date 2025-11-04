{ config, ... }:

{
  config = {
    services.taskwarrior-sync = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/taskwarrior-sync.service
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.service \
        ${./basic-service-expected.service}

      assertFileExists home-files/.config/systemd/user/taskwarrior-sync.timer
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.timer \
        ${./basic-service-expected.timer}
    '';
  };
}
