{ config, ... }:

{
  config = {
    services.betterlockscreen = {
      enable = true;
      arguments = [
        "--display"
        "1"
        "--blur"
        "0.5"
      ];
    };

    nmt.script = ''
      xssService=home-files/.config/systemd/user/xss-lock.service

      assertFileExists $xssService
      assertFileRegex $xssService 'ExecStart=.*betterlockscreen --lock --display 1 --blur 0.5'
      assertFileRegex $xssService 'Restart=always'
    '';
  };
}
