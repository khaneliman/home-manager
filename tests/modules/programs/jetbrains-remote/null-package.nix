{
  config = {
    programs.jetbrains-remote = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, jetbrains-remote should not be added to home.packages
      assertPathNotExists home-path/bin/jetbrains-remote
    '';
  };
}
