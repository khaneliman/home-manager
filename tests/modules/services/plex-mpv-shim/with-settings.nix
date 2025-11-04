{
  config = {
    services.plex-mpv-shim = {
      enable = true;
      settings = {
        adaptive_transcode = false;
        auto_play = true;
        auto_transcode = true;
      };
    };

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/plex-mpv-shim.service
      configFile=$TESTED/home-files/.config/plex-mpv-shim/conf.json

      assertFileExists $serviceFile
      assertFileExists $configFile

      # Test service configuration
      assertFileRegex $serviceFile 'ExecStart=.*plex-mpv-shim'

      # Test JSON configuration file content
      assertFileRegex $configFile '"adaptive_transcode": false'
      assertFileRegex $configFile '"auto_play": true'
      assertFileRegex $configFile '"auto_transcode": true'
    '';
  };
}
