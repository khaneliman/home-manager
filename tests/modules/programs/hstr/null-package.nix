{
  config = {
    programs.hstr = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, hstr should not be added to home.packages
      assertPathNotExists home-path/bin/hstr
    '';
  };
}
