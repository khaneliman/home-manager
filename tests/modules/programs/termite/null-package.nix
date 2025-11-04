{
  config = {
    programs.termite = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, termite should not be added to home.packages
      assertPathNotExists home-path/bin/termite
    '';
  };
}
