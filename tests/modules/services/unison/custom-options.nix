{ config, ... }:

{
  config = {
    services.unison = {
      enable = true;
      pairs = {
        "custom-sync" = {
          roots = [
            "/home/user/sync"
            "/mnt/backup/sync"
          ];
          stateDirectory = "/home/user/.unison";
          commandOptions = {
            repeat = "10";
            times = "1";
            silent = "true";
          };
        };
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/unison-pair-custom-sync.service \
        ${./custom-options-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/unison-pair-custom-sync.timer \
        ${./custom-options-expected.timer}
    '';
  };
}
