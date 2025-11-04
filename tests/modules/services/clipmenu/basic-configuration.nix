{ config, ... }:

{
  config = {
    services.clipmenu = {
      enable = true;
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/clipmenu.service

      assertFileExists $serviceFile
      assertFileRegex $serviceFile 'Description=Clipboard management daemon'
      assertFileRegex $serviceFile 'ExecStart=.*clipmenud'
      assertFileRegex $serviceFile 'Environment=PATH=.*coreutils.*findutils.*gnugrep.*gnused.*systemd'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'

      # Check that CM_LAUNCHER is not set when launcher is null
      sessionVariablesFile=home-files/.profile
      if [[ -f $sessionVariablesFile ]]; then
        assertFileNotRegex $sessionVariablesFile 'CM_LAUNCHER'
      fi
    '';
  };
}
