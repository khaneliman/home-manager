{
  config = {
    programs.rbenv = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, rbenv should not be added to home.packages
      assertPathNotExists home-path/bin/rbenv
    '';
  };
}
