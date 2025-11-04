{
  config = {
    programs.password-store = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, pass should not be added to home.packages
      assertPathNotExists home-path/bin/pass
    '';
  };
}
