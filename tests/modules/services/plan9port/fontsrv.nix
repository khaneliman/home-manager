{
  config = {
    services.plan9port.fontsrv.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/fontsrv.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=the Plan 9 file system access to host fonts'
      assertFileRegex $serviceFile 'WantedBy=default.target'
      assertFileRegex $serviceFile 'ExecStart=.*9.*fontsrv'
    '';
  };
}
