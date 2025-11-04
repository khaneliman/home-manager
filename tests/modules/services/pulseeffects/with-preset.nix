{
  config = {
    services.pulseeffects = {
      enable = true;
      preset = "my-preset";
    };

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/pulseeffects.service
      assertFileExists $serviceFile

      # Test preset option is included in ExecStart
      assertFileRegex $serviceFile 'ExecStart=.*pulseeffects --gapplication-service --load-preset my-preset'
    '';
  };
}
