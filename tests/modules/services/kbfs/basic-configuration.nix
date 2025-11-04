{
  config = {
    services.kbfs.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/kbfs.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Keybase File System'
      assertFileRegex $serviceFile 'Requires=keybase.service'
      assertFileRegex $serviceFile 'After=keybase.service'
      assertFileRegex $serviceFile 'WantedBy=default.target'

      # Test service configuration
      assertFileRegex $serviceFile 'Environment=PATH=/run/wrappers/bin'
      assertFileRegex $serviceFile 'Environment=KEYBASE_SYSTEMD=1'
      assertFileRegex $serviceFile 'ExecStartPre=.*mkdir -p "%h/keybase"'
      assertFileRegex $serviceFile 'ExecStart=.*kbfsfuse "%h/keybase"'
      assertFileRegex $serviceFile 'ExecStopPost=/run/wrappers/bin/fusermount -u "%h/keybase"'
      assertFileRegex $serviceFile 'Restart=on-failure'

      # Test that keybase service is also enabled as dependency
      keybaseServiceFile=$TESTED/home-files/.config/systemd/user/keybase.service
      assertFileExists $keybaseServiceFile
    '';
  };
}
