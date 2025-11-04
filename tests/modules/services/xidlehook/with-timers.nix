{ config, pkgs, ... }:

{
  config = {
    services.xidlehook = {
      enable = true;
      timers = [
        {
          delay = 60;
          command = "${pkgs.libnotify}/bin/notify-send 'Idle' 'Sleeping in 1 minute'";
          canceller = "${pkgs.libnotify}/bin/notify-send 'Idle' 'Resuming activity'";
        }
        {
          delay = 120;
          command = "xrandr --output HDMI1 --brightness .1";
        }
      ];
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xidlehook.service
      assertFileRegex \
        home-files/.config/systemd/user/xidlehook.service \
        'ExecStart=.*--timer 60.*notify-send.*--timer 120.*xrandr'
    '';
  };
}
