{
  config = {
    programs.starship = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, starship should not be added to home.packages
      assertPathNotExists home-path/bin/starship
    '';
  };
}
