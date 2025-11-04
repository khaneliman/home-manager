{
  config = {
    programs.tiny = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, tiny should not be added to home.packages
      assertPathNotExists home-path/bin/tiny
    '';
  };
}
