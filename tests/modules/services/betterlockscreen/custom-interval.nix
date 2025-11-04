{ config, ... }:

{
  config = {
    services.betterlockscreen = {
      enable = true;
      inactiveInterval = 15;
    };

    nmt.script = ''
      xautolockService=home-files/.config/systemd/user/xautolock-session.service

      assertFileExists $xautolockService
      assertFileRegex $xautolockService 'ExecStart=.*xautolock.*-time 15'
      assertFileRegex $xautolockService 'Restart=always'
    '';
  };
}
