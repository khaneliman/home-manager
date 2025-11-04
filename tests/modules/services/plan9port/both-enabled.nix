{
  config = {
    services.plan9port = {
      fontsrv.enable = true;
      plumber.enable = true;
    };

    nmt.script = ''
      fontsrvFile=$TESTED/home-files/.config/systemd/user/fontsrv.service
      plumberFile=$TESTED/home-files/.config/systemd/user/plumber.service

      assertFileExists $fontsrvFile
      assertFileExists $plumberFile

      # Test both services are configured
      assertFileRegex $fontsrvFile 'ExecStart=.*9.*fontsrv'
      assertFileRegex $plumberFile 'ExecStart=.*9.*plumber -f'
    '';
  };
}
