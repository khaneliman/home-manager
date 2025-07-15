{
  config = {
    programs.jq.enable = true;

    nmt.script = ''
      hmEnvFile=home-path/etc/profile.d/hm-session-vars.sh
      assertFileExists $hmEnvFile
      assertFileNotRegex $hmEnvFile 'JQ_COLORS'
    '';
  };
}
