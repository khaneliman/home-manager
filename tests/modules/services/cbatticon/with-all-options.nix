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
      assertFileRegex $serviceFile '--command-critical-level'
      assertFileRegex $serviceFile '--command-left-click'
      assertFileRegex $serviceFile '--icon-type symbolic'
      assertFileRegex $serviceFile '--low-level 15'
      assertFileRegex $serviceFile '--critical-level 5'
      assertFileRegex $serviceFile '--update-interval 10'
      assertFileRegex $serviceFile '--hide-notification'
      assertFileRegex $serviceFile 'BAT0'

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
