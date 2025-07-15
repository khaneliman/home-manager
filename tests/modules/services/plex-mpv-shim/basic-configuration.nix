{
  config = {
    services.plex-mpv-shim.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/plex-mpv-shim.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Plex mpv shim'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'
      assertFileRegex $serviceFile 'After=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'

      # Test service executable
      assertFileRegex $serviceFile 'ExecStart=.*plex-mpv-shim'

      # Test no config file is created when settings is empty
      assertPathNotExists home-path/.config/plex-mpv-shim/conf.json
    '';
  };
}
