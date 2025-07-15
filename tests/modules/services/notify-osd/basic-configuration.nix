{
  config = {
    services.notify-osd.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/notify-osd.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=notify-osd'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'

      # Test service configuration
      assertFileRegex $serviceFile 'ExecStart=.*notify-osd'
      assertFileRegex $serviceFile 'Restart=on-abort'
    '';
  };
}
