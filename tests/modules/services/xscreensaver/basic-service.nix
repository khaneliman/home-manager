{ config, ... }:

{
  config = {
    services.xscreensaver = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xscreensaver.service
      assertFileContent \
        home-files/.config/systemd/user/xscreensaver.service \
        ${./basic-service-expected.service}

      # Check that package is in home.packages
      assertFileRegex \
        home-path/bin/xscreensaver \
        '.*'
    '';
  };
}
