{
  config = {
    programs.jq = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, jq should not be added to home.packages
      assertPathNotExists home-path/bin/jq
    '';
  };
}
