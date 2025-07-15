{ config, ... }:

{
  config = {
    programs.gcc = {
      enable = true;
      package = null;
      colors = {
        error = "01;31";
      };
    };

    nmt.script = ''
      hmEnvFile=home-path/etc/profile.d/hm-session-vars.sh
      assertFileExists $hmEnvFile
      assertFileRegex $hmEnvFile 'export GCC_COLORS="error=01;31"'

      # Ensure no gcc package is installed when package = null
      assertPathNotExists home-path/bin/gcc
    '';
  };
}
