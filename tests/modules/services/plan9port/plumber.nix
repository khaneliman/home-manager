{
  config = {
    services.plan9port.plumber.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/plumber.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=file system for interprocess messaging'
      assertFileRegex $serviceFile 'WantedBy=default.target'
      assertFileRegex $serviceFile 'ExecStart=.*9.*plumber -f'
    '';
  };
}
