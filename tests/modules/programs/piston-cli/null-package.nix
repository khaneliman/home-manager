{
  config = {
    programs.piston-cli = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, piston should not be added to home.packages
      assertPathNotExists home-path/bin/piston
    '';
  };
}
