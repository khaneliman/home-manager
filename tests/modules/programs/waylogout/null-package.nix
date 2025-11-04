{
  config = {
    programs.waylogout = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, waylogout should not be added to home.packages
      assertPathNotExists home-path/bin/waylogout
    '';
  };
}
