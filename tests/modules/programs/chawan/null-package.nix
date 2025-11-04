{
  config = {
    programs.chawan = {
      enable = true;
      package = null;
      settings = {
        buffer.images = true;
      };
    };

    nmt.script = ''
      # Config files should still be created
      assertFileExists home-files/.config/chawan/config.toml

      # But package should not be installed
      assertPathNotExists home-path/bin/cha
    '';
  };
}
