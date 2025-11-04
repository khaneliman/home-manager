{
  config = {
    programs.fd = {
      enable = true;
      package = null;
      ignores = [ ".git/" ];
    };

    nmt.script = ''
      # Config files should still be created
      assertFileExists home-files/.config/fd/ignore

      # But package should not be installed
      assertPathNotExists home-path/bin/fd
    '';
  };
}
