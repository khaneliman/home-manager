{ config, ... }:

{
  config = {
    services.xsuspender = {
      enable = true;
      debug = true;
      defaults = {
        suspendDelay = 15;
        resumeEvery = 30;
        resumeFor = 10;
        onlyOnBattery = true;
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xsuspender.service
      assertFileExists home-files/.config/xsuspender.conf

      # Check service has debug environment
      assertFileRegex \
        home-files/.config/systemd/user/xsuspender.service \
        'Environment=G_MESSAGES_DEBUG=all'

      # Check default configuration
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        '\[Default\]'
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        'suspend_delay=15'
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        'resume_every=30'
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        'resume_for=10'
      assertFileRegex \
        home-files/.config/xsuspender.conf \
        'only_on_battery=true'
    '';
  };
}
