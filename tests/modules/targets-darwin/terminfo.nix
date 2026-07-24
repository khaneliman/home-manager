{
  config = {
    nmt.script = ''
      sessionVarsFile=home-path/etc/profile.d/hm-session-vars.sh
      assertFileExists $sessionVarsFile
      assertFileContains $sessionVarsFile \
        'export TERMINFO_DIRS="/home/hm-user/.nix-profile/share/terminfo:''${TERMINFO_DIRS-}''${TERMINFO_DIRS:+:}/usr/share/terminfo"'
      assertFileContains $sessionVarsFile \
        'export TERM="$TERM"'

      (
        export TERM="dumb" TERMINFO_DIRS="/inherited/terminfo"
        . "$TESTED/$sessionVarsFile"
        expected="/home/hm-user/.nix-profile/share/terminfo:/inherited/terminfo:/usr/share/terminfo"
        [ "$TERMINFO_DIRS" = "$expected" ] \
          || { echo "after first source: $TERMINFO_DIRS"; exit 1; }
        . "$TESTED/$sessionVarsFile"
        [ "$TERMINFO_DIRS" = "$expected" ] \
          || { echo "after re-source: $TERMINFO_DIRS"; exit 1; }
      ) || fail "default Darwin TERMINFO_DIRS is not idempotent"
    '';
  };
}
