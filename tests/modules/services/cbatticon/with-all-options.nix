{
  config = {
    services.cbatticon = {
      enable = true;
      commandCriticalLevel = ''
        notify-send "battery critical!"
        systemctl suspend
      '';
      commandLeftClick = "gnome-power-statistics";
      iconType = "symbolic";
      lowLevelPercent = 15;
      criticalLevelPercent = 5;
      updateIntervalSeconds = 10;
      hideNotification = true;
      batteryId = "BAT0";
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/cbatticon.service
      assertFileExists $serviceFile

      # Test that command line options are present
      assertFileRegex $serviceFile 'ExecStart=.*cbatticon'
      assertFileContains $serviceFile ' --command-critical-level'
      assertFileContains $serviceFile ' --command-left-click'
      assertFileContains $serviceFile ' --icon-type symbolic'
      assertFileContains $serviceFile ' --low-level 15'
      assertFileContains $serviceFile ' --critical-level 5'
      assertFileContains $serviceFile ' --update-interval 10'
      assertFileContains $serviceFile ' --hide-notification'
      assertFileContains $serviceFile 'BAT0'

      # Test systemd service dependencies
      assertFileRegex $serviceFile 'Requires=tray.target'
      assertFileRegex $serviceFile 'After=.*graphical-session.target'
      assertFileRegex $serviceFile 'After=.*tray.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'Restart=on-abort'
    '';
  };
}
