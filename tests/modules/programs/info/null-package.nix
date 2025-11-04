{
  config = {
    programs.info = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, info should not be added to home.packages
      assertPathNotExists home-path/bin/info
    '';
  };
}
