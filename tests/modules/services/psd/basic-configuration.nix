{
  config = {
    services.psd.enable = true;

    nmt.script = ''
      psdService=$TESTED/home-files/.config/systemd/user/psd.service
      resyncService=$TESTED/home-files/.config/systemd/user/psd-resync.service
      resyncTimer=$TESTED/home-files/.config/systemd/user/psd-resync.timer
      configFile=$TESTED/home-files/.config/psd/psd.conf

      assertFileExists $psdService
      assertFileExists $resyncService
      assertFileExists $resyncTimer
      assertFileExists $configFile

      # Test main psd service
      assertFileRegex $psdService 'Description=Profile-sync-daemon'
      assertFileRegex $psdService 'Type=oneshot'
      assertFileRegex $psdService 'RemainAfterExit=yes'
      assertFileRegex $psdService 'ExecStart=.*profile-sync-daemon startup'
      assertFileRegex $psdService 'ExecStop=.*profile-sync-daemon unsync'
      assertFileRegex $psdService 'WantedBy=default.target'

      # Test resync service
      assertFileRegex $resyncService 'Description=Timed profile resync'
      assertFileRegex $resyncService 'ExecStart=.*profile-sync-daemon resync'

      # Test resync timer
      assertFileRegex $resyncTimer 'Description=Timer for Profile-sync-daemon'
      assertFileRegex $resyncTimer 'OnUnitActiveSec=1h'

      # Test default configuration file
      assertFileRegex $configFile 'USE_BACKUP="yes"'
      assertFileRegex $configFile 'BACKUP_LIMIT=5'
    '';
  };
}
