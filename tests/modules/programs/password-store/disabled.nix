{ config, ... }:

{
  config = {
    programs.password-store = {
      enable = false;
      settings = {
        PASSWORD_STORE_DIR = "/should/not/be/set";
        PASSWORD_STORE_KEY = "NOTSET";
      };
    };

    nmt.script = ''
      # Test that no password-store package is installed when disabled
      assertPathNotExists home-path/bin/pass

      # Test that no session variables are set when disabled
      hmEnvFile=home-path/etc/profile.d/hm-session-vars.sh
      if [[ -f $hmEnvFile ]]; then
        assertFileNotRegex $hmEnvFile 'PASSWORD_STORE'
      fi
    '';
  };
}
