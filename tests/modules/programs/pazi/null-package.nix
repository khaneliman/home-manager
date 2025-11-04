{
  config = {
    programs.pazi = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, pazi should not be added to home.packages
      assertPathNotExists home-path/bin/pazi
    '';
  };
}
