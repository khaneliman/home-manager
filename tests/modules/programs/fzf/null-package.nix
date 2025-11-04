{
  config = {
    programs.fzf = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, fzf should not be added to home.packages
      assertPathNotExists home-path/bin/fzf
    '';
  };
}
