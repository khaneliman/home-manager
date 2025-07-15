{
  config = {
    programs.jq = {
      enable = true;
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
      hmEnvFile=home-path/etc/profile.d/hm-session-vars.sh
      assertFileExists $hmEnvFile
      assertFileRegex $hmEnvFile 'JQ_COLORS="1;30:0;31:0;32:0;36:0;33:1;35:1;37:1;34"'
    '';
  };
}
