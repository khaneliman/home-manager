{
  config = {
    programs.tealdeer = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, tldr should not be added to home.packages
      assertPathNotExists home-path/bin/tldr
    '';
  };
}
