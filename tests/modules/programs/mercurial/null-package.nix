{
  config = {
    programs.mercurial = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, mercurial should not be added to home.packages
      assertPathNotExists home-path/bin/hg
    '';
  };
}
