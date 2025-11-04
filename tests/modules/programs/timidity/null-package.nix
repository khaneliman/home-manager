{
  config = {
    programs.timidity = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, timidity should not be added to home.packages
      assertPathNotExists home-path/bin/timidity
    '';
  };
}
