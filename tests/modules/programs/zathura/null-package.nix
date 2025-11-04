{
  config = {
    programs.zathura = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, zathura should not be added to home.packages
      assertPathNotExists home-path/bin/zathura
    '';
  };
}
