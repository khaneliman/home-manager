{
  config = {
    services.stalonetray.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/stalonetray.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Stalonetray system tray'
      assertFileRegex $serviceFile 'WantedBy=tray.target'
      assertFileRegex $serviceFile 'PartOf=tray.target'

      # Test service configuration
      assertFileRegex $serviceFile 'ExecStart=.*stalonetray'
      assertFileRegex $serviceFile 'Restart=on-failure'

      # Test no config file is created when config is empty
      assertPathNotExists home-path/.config/stalonetrayrc
    '';
  };
}
