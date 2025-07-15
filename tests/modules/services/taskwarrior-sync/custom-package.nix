{ config, pkgs, ... }:

{
  config = {
    services.taskwarrior-sync = {
      enable = true;
      package = pkgs.taskwarrior3;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.service \
        ${./custom-package-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/taskwarrior-sync.timer \
        ${./custom-package-expected.timer}
    '';
  };
}
