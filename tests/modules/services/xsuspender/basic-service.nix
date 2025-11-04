{ config, ... }:

{
  config = {
    services.xsuspender = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xsuspender.service
      assertFileContent \
        home-files/.config/systemd/user/xsuspender.service \
        ${./basic-service-expected.service}

      assertFileExists home-files/.config/xsuspender.conf

      # Check that package is in home.packages
      assertFileRegex \
        home-path/bin/xsuspender \
        '.*'
    '';
  };
}
