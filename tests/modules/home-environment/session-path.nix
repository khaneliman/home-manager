{
  home.sessionPath = [
    "bar"
    "baz"
    "foo"
  ];

  nmt.script = ''
    hmSessVars=home-path/etc/profile.d/hm-session-vars.sh
    assertFileExists $hmSessVars
    assertFileContains $hmSessVars \
      '__hm_new="bar:baz:foo"'
    assertFileContains $hmSessVars \
      '__hm_cur="''${PATH-}"'
    assertFileContains $hmSessVars \
      '  export PATH="$__hm_add''${__hm_cur:+:}$__hm_cur"'

    # Runtime semantics: add-if-missing, idempotent re-source, no reorder.
    (
      # The Darwin extra section references TERM and TERMINFO_DIRS, which
      # are unset in the sandbox and would trip the test shell's `set -u`.
      export TERM="dumb" TERMINFO_DIRS=""
      export PATH="baz:/existing"
      . "$TESTED/$hmSessVars"
      [ "$PATH" = "bar:foo:baz:/existing" ] \
        || { echo "after first source: $PATH"; exit 1; }
      . "$TESTED/$hmSessVars"
      [ "$PATH" = "bar:foo:baz:/existing" ] \
        || { echo "after re-source: $PATH"; exit 1; }
    ) || fail "hm-session-vars.sh runtime semantics broken"
  '';
}
