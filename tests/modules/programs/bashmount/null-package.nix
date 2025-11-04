{
  config = {
    programs.bashmount = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # Config files should still be created
      assertFileExists home-files/.config/bashmount/config

      # But package should not be installed
      assertPathNotExists home-path/bin/bashmount
    '';
  };
}
