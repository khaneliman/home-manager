{
  config = {
    services.librespot.enable = true;

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/librespot.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Librespot (an open source Spotify client)'
      assertFileRegex $serviceFile 'WantedBy=.*default.target'
      assertFileRegex $serviceFile 'Restart=always'
      assertFileRegex $serviceFile 'RestartSec=12'

      # Test executable
      assertFileRegex $serviceFile 'ExecStart=.*librespot'
    '';
  };
}
