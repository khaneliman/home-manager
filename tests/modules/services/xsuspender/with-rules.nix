{ config, ... }:

{
  config = {
    services.xsuspender = {
      enable = true;
      rules = {
        Chromium = {
          suspendDelay = 10;
          matchWmClassContains = "chromium-browser";
          suspendSubtreePattern = "chromium";
        };
        Firefox = {
          suspendDelay = 5;
          matchWmClassContains = "firefox";
          onlyOnBattery = true;
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xsuspender.service
      assertFileExists home-files/.config/xsuspender.conf

      # Check configuration content
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        '\[Chromium\]'
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        'suspend_delay=10'
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        'match_wm_class_contains=chromium-browser'
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        '\[Firefox\]'
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        'only_on_battery=true'
    '';
  };
}
