{
  config = {
    programs.joshuto = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, joshuto should not be added to home.packages
      assertPathNotExists home-path/bin/joshuto
    '';
  };
}
