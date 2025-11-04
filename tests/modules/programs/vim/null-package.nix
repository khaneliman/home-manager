{
  config = {
    programs.vim = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, vim should not be added to home.packages
      assertPathNotExists home-path/bin/vim
    '';
  };
}
