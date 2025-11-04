{
  config = {
    programs.pylint = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, pylint should not be added to home.packages
      assertPathNotExists home-path/bin/pylint
    '';
  };
}
