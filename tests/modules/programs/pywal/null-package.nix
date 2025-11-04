{
  config = {
    programs.pywal = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, wal should not be added to home.packages
      assertPathNotExists home-path/bin/wal
    '';
  };
}
