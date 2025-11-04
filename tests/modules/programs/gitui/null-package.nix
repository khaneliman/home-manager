{
  config = {
    programs.gitui = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, gitui should not be added to home.packages
      assertPathNotExists home-path/bin/gitui
    '';
  };
}
