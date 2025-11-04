{
  config = {
    programs.home-manager = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, home-manager should not be added to home.packages
      assertPathNotExists home-path/bin/home-manager
    '';
  };
}
