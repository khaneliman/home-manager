{
  config = {
    services.owncloud-client.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/owncloud-client.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Owncloud Client'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'

      # Test service executable and environment
      assertFileRegex $serviceFile 'ExecStart=.*owncloud'
      assertFileRegex $serviceFile 'Environment=PATH='
    '';
  };
}
