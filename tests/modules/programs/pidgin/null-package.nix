{
  config = {
    programs.pidgin = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, pidgin should not be added to home.packages
      assertPathNotExists home-path/bin/pidgin
    '';
  };
}
