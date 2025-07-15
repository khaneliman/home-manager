{
  config = {
    services.kbfs = {
      enable = true;
      mountPoint = "custom-keybase-mount";
      extraFlags = [
        "-label kbfs"
        "-mount-type normal"
        "-debug"
      ];
    };

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/kbfs.service
      assertFileExists $serviceFile

      # Test custom mount point
      assertFileRegex $serviceFile 'ExecStartPre=.*mkdir -p "%h/custom-keybase-mount"'
      assertFileRegex $serviceFile 'ExecStart=.*kbfsfuse -label kbfs -mount-type normal -debug "%h/custom-keybase-mount"'
      assertFileRegex $serviceFile 'ExecStopPost=/run/wrappers/bin/fusermount -u "%h/custom-keybase-mount"'

      # Test environment variables are still set
      assertFileRegex $serviceFile 'Environment=PATH=/run/wrappers/bin'
      assertFileRegex $serviceFile 'Environment=KEYBASE_SYSTEMD=1'

      # Test dependencies are still correct
      assertFileRegex $serviceFile 'Requires=keybase.service'
      assertFileRegex $serviceFile 'After=keybase.service'
    '';
  };
}
