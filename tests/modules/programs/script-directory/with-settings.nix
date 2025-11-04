{ config, ... }:

{
  programs.script-directory = {
    enable = true;
    settings = {
      SD_ROOT = "${config.home.homeDirectory}/.sd";
      SD_EDITOR = "nvim";
      SD_CAT = "lolcat";
    };
  };

  nmt.script = ''
    # Check that variables are available in the session
    hmSessionVars=home-path/etc/profile.d/hm-session-vars.sh
    if [[ -f "$hmSessionVars" ]]; then
      assertFileExists "$hmSessionVars"
      assertFileRegex "$hmSessionVars" 'SD_ROOT'
      assertFileRegex "$hmSessionVars" 'SD_EDITOR'
      assertFileRegex "$hmSessionVars" 'SD_CAT'
    fi
  '';
}
