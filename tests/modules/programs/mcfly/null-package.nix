{
  config = {
    programs.mcfly = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, mcfly should not be added to home.packages
      assertPathNotExists home-path/bin/mcfly
    '';
  };
}
