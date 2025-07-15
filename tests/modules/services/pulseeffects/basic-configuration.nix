{
  config = {
    services.pulseeffects.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/pulseeffects.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Pulseeffects daemon'
      assertFileRegex $serviceFile 'Requires=dbus.service'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=pulseaudio.service'

      # Test service executable and options  
      assertFileRegex $serviceFile 'ExecStart=.*pulseeffects --gapplication-service'
      assertFileRegex $serviceFile 'ExecStop=.*pulseeffects --quit'
      assertFileRegex $serviceFile 'Restart=on-failure'
      assertFileRegex $serviceFile 'RestartSec=5'

      # Test no preset option when not specified
      assertFileNotRegex $serviceFile -- '--load-preset'
    '';
  };
}
