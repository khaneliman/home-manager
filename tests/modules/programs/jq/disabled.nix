{ config, ... }:

{
  config = {
    programs.jq = {
      enable = false;
      colors = {
        null = "1;30";
        false = "0;31";
        true = "0;32";
        numbers = "0;36";
        strings = "0;33";
        arrays = "1;35";
        objects = "1;37";
        objectKeys = "1;34";
      };
    };

    nmt.script = ''
      # Test that no jq package is installed when disabled
      assertPathNotExists home-path/bin/jq

      # Test that JQ_COLORS environment variable is not set when disabled
      hmEnvFile=home-path/etc/profile.d/hm-session-vars.sh
      if [[ -f $hmEnvFile ]]; then
        assertFileNotRegex $hmEnvFile 'JQ_COLORS'
      fi
    '';
  };
}
