{ config, ... }:

{
  config = {
    services.xidlehook = {
      enable = true;
      once = true;
      detect-sleep = true;
      not-when-fullscreen = true;
      not-when-audio = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xidlehook.service
      assertFileRegex \
        home-files/.config/systemd/user/xidlehook.service \
        'Type=oneshot'
      assertFileRegex \
        home-files/.config/systemd/user/xidlehook.service \
        'ExecStart=.*--once.*--detect-sleep.*--not-when-fullscreen.*--not-when-audio'
    '';
  };
}
