{
  config = {
    programs.urxvt = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, urxvt should not be added to home.packages
      assertPathNotExists home-path/bin/urxvt
    '';
  };
}
