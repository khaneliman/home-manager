{ config, pkgs, ... }:

{
  config = {
    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_DIR = "/custom/password/dir";
        PASSWORD_STORE_KEY = "ABCD1234";
        PASSWORD_STORE_CLIP_TIME = "45";
      };
    };

    nmt.script = ''
      # Test that password-store package with extensions is installed
      assertFileExists home-path/bin/pass
      assertFileExists home-path/lib/password-store/extensions/otp.bash

      # Test custom session variables are set
      assertFileExists home-path/etc/profile.d/hm-session-vars.sh
      assertFileContains \
        home-path/etc/profile.d/hm-session-vars.sh \
        'export PASSWORD_STORE_DIR="/custom/password/dir"'

      assertFileContains \
        home-path/etc/profile.d/hm-session-vars.sh \
        'export PASSWORD_STORE_KEY="ABCD1234"'

      assertFileContains \
        home-path/etc/profile.d/hm-session-vars.sh \
        'export PASSWORD_STORE_CLIP_TIME="45"'
    '';
  };
}
