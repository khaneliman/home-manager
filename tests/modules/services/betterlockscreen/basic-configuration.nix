{ config, ... }:

{
  config = {
    services.betterlockscreen = {
      enable = true;
    };

    nmt.script = ''
      xssService=home-files/.config/systemd/user/xss-lock.service
      xautolockService=home-files/.config/systemd/user/xautolock-session.service

      assertFileExists $xssService
      assertFileRegex $xssService 'ExecStart=.*betterlockscreen --lock'
      assertFileRegex $xssService 'Restart=always'

      assertFileExists $xautolockService
      assertFileRegex $xautolockService 'ExecStart=.*xautolock.*-time 10'
      assertFileRegex $xautolockService 'Restart=always'
    '';
  };
}
