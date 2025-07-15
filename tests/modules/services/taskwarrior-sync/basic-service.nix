{ config, ... }:

{
  config = {
    services.taskwarrior-sync = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.service \
        ${./basic-service-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.timer \
        ${./basic-service-expected.timer}
    '';
  };
}
