{
  config = {
    programs.quickshell = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, quickshell should not be added to home.packages
      assertPathNotExists home-path/bin/quickshell
    '';
  };
}
