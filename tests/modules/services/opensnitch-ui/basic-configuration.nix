{
  config = {
    services.opensnitch-ui.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/opensnitch-ui.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Opensnitch ui'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'

      # Test service executable and environment
      assertFileRegex $serviceFile 'ExecStart=.*opensnitch-ui'
      assertFileRegex $serviceFile 'Environment=PATH='
    '';
  };
}
