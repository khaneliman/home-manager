{
  config = {
    services.listenbrainz-mpd.enable = true;

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/listenbrainz-mpd.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=ListenBrainz submission client for MPD'
      assertFileRegex $serviceFile 'Documentation=https://codeberg.org/elomatreb/listenbrainz-mpd'
      assertFileRegex $serviceFile 'After=.*mpd.service'
      assertFileRegex $serviceFile 'Requires=.*mpd.service'
      assertFileRegex $serviceFile 'WantedBy=.*default.target'
      assertFileRegex $serviceFile 'Restart=always'
      assertFileRegex $serviceFile 'RestartSec=5'

      # Test executable
      assertFileRegex $serviceFile 'ExecStart=.*listenbrainz-mpd'
    '';
  };
}
