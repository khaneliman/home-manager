{
  config = {
    services.psd = {
      enable = true;
      browsers = [
        "firefox"
        "chromium"
      ];
      useBackup = false;
      backupLimit = 10;
      resyncTimer = "30min";
    };

    nmt.script = ''
      resyncTimer=$TESTED/home-files/.config/systemd/user/psd-resync.timer
      configFile=$TESTED/home-files/.config/psd/psd.conf

      assertFileExists $resyncTimer
      assertFileExists $configFile

      # Test custom timer interval
      assertFileRegex $resyncTimer 'OnUnitActiveSec=30min'

      # Test custom configuration settings
      assertFileRegex $configFile 'BROWSERS=(firefox chromium)'
      assertFileRegex $configFile 'USE_BACKUP="no"'
      assertFileRegex $configFile 'BACKUP_LIMIT=10'
    '';
  };
}
