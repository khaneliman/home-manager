{
  config = {
    programs.lazygit = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, lazygit should not be added to home.packages
      assertPathNotExists home-path/bin/lazygit
    '';
  };
}
