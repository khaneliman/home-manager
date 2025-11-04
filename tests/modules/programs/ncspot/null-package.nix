{
  config = {
    programs.ncspot = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, ncspot should not be added to home.packages
      assertPathNotExists home-path/bin/ncspot
    '';
  };
}
