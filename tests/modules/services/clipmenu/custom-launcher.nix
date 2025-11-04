{ config, ... }:

{
  config = {
    services.clipmenu = {
      enable = true;
      launcher = "rofi";
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/clipmenu.service

      assertFileExists $serviceFile
      assertFileRegex $serviceFile 'Description=Clipboard management daemon'
      assertFileRegex $serviceFile 'ExecStart=.*clipmenud'
      assertFileRegex $serviceFile 'Environment=PATH=.*coreutils.*findutils.*gnugrep.*gnused.*systemd'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'

      # Check that CM_LAUNCHER is set when launcher is specified  
      sessionVariablesFile=home-path/etc/profile.d/hm-session-vars.sh
      assertFileExists $sessionVariablesFile
      assertFileRegex $sessionVariablesFile 'export CM_LAUNCHER="rofi"'
    '';
  };
}
