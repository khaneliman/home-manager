{ config, ... }:

{
  config = {
    programs.afew = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      assertFileExists home-files/.config/afew/config
      assertFileContent \
        home-files/.config/afew/config \
        ${./basic-configuration-expected.config}

      # Ensure no afew package is installed when package = null
      assertPathNotExists home-path/bin/afew
    '';
  };
}
