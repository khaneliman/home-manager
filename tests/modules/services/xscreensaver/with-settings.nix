{ config, ... }:

{
  config = {
    services.xscreensaver = {
      enable = true;
      settings = {
        mode = "blank";
        lock = false;
        fadeTicks = 20;
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xscreensaver.service

      # Check xresources properties are set
      assertFileRegex \
        home-files/.Xresources \
        'xscreensaver\.mode:.*blank'
      assertFileRegex \
        home-files/.Xresources \
        'xscreensaver\.lock:.*false'
      assertFileRegex \
        home-files/.Xresources \
        'xscreensaver\.fadeTicks:.*20'
    '';
  };
}
