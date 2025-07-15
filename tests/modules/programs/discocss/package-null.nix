{ config, ... }:

{
  config = {
    programs.discocss = {
      enable = true;
      package = null;
      css = "/* test css */";
    };

    nmt.script = ''
      assertFileExists home-files/.config/discocss/custom.css
      assertFileRegex home-files/.config/discocss/custom.css "test css"

      # Ensure no discocss package is installed when package = null
      assertPathNotExists home-path/bin/discocss
    '';
  };
}
