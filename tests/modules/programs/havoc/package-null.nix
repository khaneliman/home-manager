{ config, ... }:

{
  config = {
    programs.havoc = {
      enable = true;
      package = null;
      settings = {
        terminal.rows = 25;
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/havoc.cfg
      assertFileRegex home-files/.config/havoc.cfg 'rows=25'

      # Ensure no havoc package is installed when package = null
      assertPathNotExists home-path/bin/havoc
    '';
  };
}
