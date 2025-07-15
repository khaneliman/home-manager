{
  programs.skim = {
    enable = true;
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--height 40%"
      "--prompt ⟫"
    ];
    fileWidgetCommand = "fd --type f";
    fileWidgetOptions = [ "--preview 'head {}'" ];
    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
    historyWidgetOptions = [
      "--tac"
      "--exact"
    ];
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  nmt.script = ''
    # Check that variables are available in the session
    hmSessionVars=home-path/etc/profile.d/hm-session-vars.sh
    if [[ -f "$hmSessionVars" ]]; then
      assertFileExists "$hmSessionVars"
      assertFileRegex "$hmSessionVars" 'SKIM_DEFAULT_COMMAND'
      assertFileRegex "$hmSessionVars" 'SKIM_DEFAULT_OPTIONS'
      assertFileRegex "$hmSessionVars" 'SKIM_CTRL_T_COMMAND'
      assertFileRegex "$hmSessionVars" 'SKIM_CTRL_T_OPTS'
      assertFileRegex "$hmSessionVars" 'SKIM_ALT_C_COMMAND'
      assertFileRegex "$hmSessionVars" 'SKIM_ALT_C_OPTS'
      assertFileRegex "$hmSessionVars" 'SKIM_CTRL_R_OPTS'
    fi
  '';
}
