{
  config = {
    programs.tint2 = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, tint2 should not be added to home.packages
      assertPathNotExists home-path/bin/tint2
    '';
  };
}
