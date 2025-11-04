{ config, ... }:

{
  config = {
    services.status-notifier-watcher = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/status-notifier-watcher.service
      assertFileContent \
        home-files/.config/systemd/user/status-notifier-watcher.service \
        ${./basic-service-expected.service}
    '';
  };
}
