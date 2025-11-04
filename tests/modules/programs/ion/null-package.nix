{
  config = {
    programs.ion = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, ion should not be added to home.packages
      assertPathNotExists home-path/bin/ion
    '';
  };
}
