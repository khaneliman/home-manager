{
  config = {
    services.librespot = {
      enable = true;
      settings = {
        name = "My Speaker";
        bitrate = 320;
        cache = "/tmp/librespot";
        disable-audio-cache = true;
        backend = "alsa";
      };
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/librespot.service
      assertFileExists $serviceFile

      # Test that settings are passed as arguments
      assertFileRegex $serviceFile 'ExecStart=.*--name=My Speaker'
      assertFileRegex $serviceFile 'ExecStart=.*--bitrate=320'
      assertFileRegex $serviceFile 'ExecStart=.*--cache=/tmp/librespot'
      assertFileRegex $serviceFile 'ExecStart=.*--disable-audio-cache'
      assertFileRegex $serviceFile 'ExecStart=.*--backend=alsa'
    '';
  };
}
