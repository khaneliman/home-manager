{
  config = {
    services.mpd-discord-rpc.enable = true;

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/mpd-discord-rpc.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Discord Rich Presence for MPD'
      assertFileRegex $serviceFile 'Documentation=https://github.com/JakeStanger/mpd-discord-rpc'
      assertFileRegex $serviceFile 'After=.*graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=.*graphical-session.target'
      assertFileRegex $serviceFile 'WantedBy=.*graphical-session.target'
      assertFileRegex $serviceFile 'Restart=on-failure'

      # Test executable
      assertFileRegex $serviceFile 'ExecStart=.*mpd-discord-rpc'

      # Test configuration file exists (even if empty)
      configFile=home-files/.config/discord-rpc/config.toml
      assertFileExists $configFile
    '';
  };
}
