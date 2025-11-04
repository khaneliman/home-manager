{
  config = {
    programs.navi = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, navi should not be added to home.packages
      assertPathNotExists home-path/bin/navi
    '';
  };
}
