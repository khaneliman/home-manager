{
  config = {
    services.poweralertd.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/poweralertd.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=UPower-powered power alerter'
      assertFileRegex $serviceFile 'Documentation=man:poweralertd(1)'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'

      # Test service configuration
      assertFileRegex $serviceFile 'Type=simple'
      assertFileRegex $serviceFile 'ExecStart=.*poweralertd'
      assertFileRegex $serviceFile 'Restart=always'
    '';
  };
}
