{
  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "$HOME/.password-store";
      PASSWORD_STORE_KEY = "12345678";
      PASSWORD_STORE_CLIP_TIME = "60";
    };
  };

  nmt.script = ''
    # Verify package is installed
    assertNotNull "$(command -v pass)"

    # Verify session variables are set
    if [[ -f $HOME/.bashrc ]]; then
      assertFileRegex $HOME/.bashrc 'PASSWORD_STORE_DIR'
      assertFileRegex $HOME/.bashrc 'PASSWORD_STORE_KEY'
      assertFileRegex $HOME/.bashrc 'PASSWORD_STORE_CLIP_TIME'
    fi

    # Check that variables are available in the session
    hmSessionVars=home-path/etc/profile.d/hm-session-vars.sh
    if [[ -f "$hmSessionVars" ]]; then
      assertFileExists "$hmSessionVars"
      assertFileRegex "$hmSessionVars" 'PASSWORD_STORE_DIR'
      assertFileRegex "$hmSessionVars" 'PASSWORD_STORE_KEY'
      assertFileRegex "$hmSessionVars" 'PASSWORD_STORE_CLIP_TIME'
    fi
  '';
}
