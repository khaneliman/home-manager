{ config, pkgs, ... }:

{
  config = {
    services.taskwarrior-sync = {
      enable = true;
      package = pkgs.taskwarrior3;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/taskwarrior-sync.service
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.service \
        ${./custom-package-expected.service}

      assertFileExists home-files/.config/systemd/user/taskwarrior-sync.timer
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.timer \
        ${./custom-package-expected.timer}
    '';
  };
}
