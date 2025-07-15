{ config, ... }:

{
  config = {
    programs.password-store = {
      enable = true;
    };

    nmt.script = ''
      # Test that default settings are applied
      assertFileContains \
        home-path/etc/profile.d/hm-session-vars.sh \
        'export PASSWORD_STORE_DIR="${config.xdg.dataHome}/password-store"'
    '';
  };
}
