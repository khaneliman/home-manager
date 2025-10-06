{ config, ... }:

{
  config = {
    services.ludusavi = {
      enable = true;
      frequency = "*-*-* 8:00:00";
      backupNotification = true;
      settings = {
        language = "en-US";
        theme = "light";
        roots = [
          {
            path = "~/.local/share/Steam";
            store = "steam";
          }
        ];
        backup.path = "~/.local/state/backups/ludusavi";
        restore.path = "~/.local/state/backups/ludusavi";
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/ludusavi.service \
        ${./custom-settings-expected.service}

      assertFileContent \
        home-files/.config/systemd/user/ludusavi.timer \
        ${./custom-settings-expected.timer}

      assertFileContent \
        home-files/.config/ludusavi/config.yaml \
        ${./custom-settings-expected.yaml}
    '';
  };
}
