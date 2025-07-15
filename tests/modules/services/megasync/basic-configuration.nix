{
  config = {
    services.megasync.enable = true;

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/megasync.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=megasync'
      assertFileRegex $serviceFile 'After=.*graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=.*graphical-session.target'
      assertFileRegex $serviceFile 'WantedBy=.*graphical-session.target'

      # Test executable
      assertFileRegex $serviceFile 'ExecStart=.*megasync'

      # Test no wayland environment by default
      assertFileNotRegex $serviceFile 'Environment.*DO_NOT_UNSET_XDG_SESSION_TYPE'
    '';
  };
}
