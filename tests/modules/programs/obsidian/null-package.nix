{
  config = {
    programs.obsidian = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, obsidian should not be added to home.packages
      assertPathNotExists home-path/bin/obsidian
    '';
  };
}
