{
  config = {
    programs.obs-studio = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, obs-studio should not be added to home.packages
      assertPathNotExists home-path/bin/obs
    '';
  };
}
