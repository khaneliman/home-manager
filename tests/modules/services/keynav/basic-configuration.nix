{
  config = {
    services.keynav.enable = true;

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/keynav.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=keynav'
      assertFileRegex $serviceFile 'After=.*graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=.*graphical-session.target'
      assertFileRegex $serviceFile 'WantedBy=.*graphical-session.target'
      assertFileRegex $serviceFile 'Restart=always'
      assertFileRegex $serviceFile 'RestartSec=3'

      # Test executable
      assertFileRegex $serviceFile 'ExecStart=.*keynav'
    '';
  };
}
