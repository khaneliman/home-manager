{
  config = {
    programs.xplr = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, xplr should not be added to home.packages
      assertPathNotExists home-path/bin/xplr
    '';
  };
}
