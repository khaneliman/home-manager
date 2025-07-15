{
  config = {
    services.sctd.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/sctd.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Dynamically adjust the screen color temperature twice every minute'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'

      # Test service configuration
      assertFileRegex $serviceFile 'ExecStart=.*sctd 4500'
      assertFileRegex $serviceFile 'ExecStopPost=.*sct'
      assertFileRegex $serviceFile 'Restart=on-abnormal'
      assertFileRegex $serviceFile 'SuccessExitStatus=1'

      # Test environment PATH includes necessary tools
      assertFileRegex $serviceFile 'Environment=PATH='
    '';
  };
}
