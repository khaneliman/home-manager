{
  config = {
    services.sctd = {
      enable = true;
      baseTemperature = 3500;
    };

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/sctd.service
      assertFileExists $serviceFile

      # Test custom base temperature is used
      assertFileRegex $serviceFile 'ExecStart=.*sctd 3500'
    '';
  };
}
