{
  config = {
    services.cbatticon.enable = true;

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/cbatticon.service
      assertFileExists $serviceFile

      # Test basic systemd service configuration
      assertFileRegex $serviceFile 'Description=cbatticon system tray battery icon'
      assertFileRegex $serviceFile 'Requires=tray.target'
      assertFileRegex $serviceFile 'After=.*graphical-session.target'
      assertFileRegex $serviceFile 'After=.*tray.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'Restart=on-abort'

      # Test basic command (just cbatticon executable)
      assertFileRegex $serviceFile 'ExecStart=.*cbatticon'
    '';
  };
}
