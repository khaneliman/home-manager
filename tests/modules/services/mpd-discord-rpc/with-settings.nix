{
  config = {
    services.mpd-discord-rpc = {
      enable = true;
      settings = {
        hosts = [ "localhost:6600" ];
        format = {
          details = "$title";
          state = "On $album by $artist";
        };
      };
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/mpd-discord-rpc.service
      assertFileExists $serviceFile

      # Test configuration file with settings
      configFile=home-files/.config/discord-rpc/config.toml
      assertFileExists $configFile

      # Test TOML configuration content
      assertFileRegex $configFile 'hosts = \[ "localhost:6600" \]'
      assertFileRegex $configFile '\[format\]'
      assertFileRegex $configFile 'details = "\$title"'
      assertFileRegex $configFile 'state = "On \$album by \$artist"'
    '';
  };
}
