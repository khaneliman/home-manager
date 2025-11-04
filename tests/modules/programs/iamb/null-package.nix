{
  config = {
    programs.iamb = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, iamb should not be added to home.packages
      assertPathNotExists home-path/bin/iamb
    '';
  };
}
