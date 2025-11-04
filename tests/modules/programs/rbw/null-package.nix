{
  config = {
    programs.rbw = {
      enable = true;
      package = null;
      settings = {
        email = "user@example.com";
      };
    };

    nmt.script = ''
      # Config files should still be created
      assertFileExists home-files/.config/rbw/config.json

      # But package should not be installed
      assertPathNotExists home-path/bin/rbw
    '';
  };
}
