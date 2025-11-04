{
  config = {
    programs.chromium = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, chromium should not be added to home.packages
      assertPathNotExists home-path/bin/chromium
    '';
  };
}
