{
  config = {
    programs.script-directory = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, sd should not be added to home.packages
      assertPathNotExists home-path/bin/sd
    '';
  };
}
