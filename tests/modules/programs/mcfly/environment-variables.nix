{ config, ... }:

{
  config = {
    programs.mcfly = {
      enable = true;
      keyScheme = "vim";
      interfaceView = "BOTTOM";
      enableLightTheme = true;
      fuzzySearchFactor = 3;
    };

    nmt.script = ''
      assertFileRegex home-path/etc/profile.d/hm-session-vars.sh \
        'export MCFLY_KEY_SCHEME="vim"'

      assertFileRegex home-path/etc/profile.d/hm-session-vars.sh \
        'export MCFLY_INTERFACE_VIEW="BOTTOM"'

      assertFileRegex home-path/etc/profile.d/hm-session-vars.sh \
        'export MCFLY_LIGHT="TRUE"'

      assertFileRegex home-path/etc/profile.d/hm-session-vars.sh \
        'export MCFLY_FUZZY="3"'
    '';
  };
}
