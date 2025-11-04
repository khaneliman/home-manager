{
  config = {
    services.megasync = {
      enable = true;
      forceWayland = true;
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/megasync.service
      assertFileExists $serviceFile

      # Test wayland environment is set
      assertFileRegex $serviceFile 'Environment.*DO_NOT_UNSET_XDG_SESSION_TYPE=1'
    '';
  };
}
