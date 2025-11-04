{
  config = {
    programs.floorp = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, floorp should not be added to home.packages
      assertPathNotExists home-path/bin/floorp
    '';
  };
}
