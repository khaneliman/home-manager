{
  config = {
    programs.skim = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, sk should not be added to home.packages
      assertPathNotExists home-path/bin/sk
    '';
  };
}
