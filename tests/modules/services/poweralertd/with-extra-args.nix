{
  config = {
    services.poweralertd = {
      enable = true;
      extraArgs = [
        "-s"
        "-S"
      ];
    };

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/poweralertd.service
      assertFileExists $serviceFile

      # Test extra arguments are passed to poweralertd
      assertFileRegex $serviceFile 'ExecStart=.*poweralertd.*"-s".*"-S"'
    '';
  };
}
