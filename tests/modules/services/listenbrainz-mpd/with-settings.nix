{
  config = {
    services.listenbrainz-mpd = {
      enable = true;
      settings = {
        submission.token_file = "/run/secrets/listenbrainz-mpd";
        mpd = {
          host = "localhost";
          port = 6600;
        };
      };
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/listenbrainz-mpd.service
      assertFileExists $serviceFile

      # Test configuration file is created
      configFile=home-files/.config/listenbrainz-mpd/config.toml
      assertFileExists $configFile

      # Test TOML configuration content
      assertFileRegex $configFile 'token_file = "/run/secrets/listenbrainz-mpd"'
      assertFileRegex $configFile '\[mpd\]'
      assertFileRegex $configFile 'host = "localhost"'
      assertFileRegex $configFile 'port = 6600'
    '';
  };
}
