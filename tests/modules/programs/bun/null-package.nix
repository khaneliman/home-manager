{
  config = {
    programs.bun = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, bun should not be added to home.packages
      assertPathNotExists home-path/bin/bun
    '';
  };
}
