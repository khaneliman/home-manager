{ realPkgs, ... }:

{
  home.sessionSearchVariables = {
    TEST = [
      "bar"
      "baz"
      "bar"
      ""
      "$EMPTY_ENTRY"
      "foo"
      ""
    ];
    TEST2 = [ "qux" ];
    TEST3 = [ "$HOME/tools" ];
  };

  nmt.script = ''
    hmSessVars=home-path/etc/profile.d/hm-session-vars.sh
    assertFileExists $hmSessVars
    assertFileContains $hmSessVars \
      '__hm_new="bar:baz:bar::$EMPTY_ENTRY:foo:"'
    assertFileContains $hmSessVars \
      '__hm_cur="''${TEST-}"'
    assertFileContains $hmSessVars \
      '  export TEST="$__hm_add''${__hm_cur:+:}$__hm_cur"'
    assertFileContains $hmSessVars \
      '__hm_new="qux"'
    assertFileContains $hmSessVars \
      '__hm_cur="''${TEST2-}"'
    assertFileContains $hmSessVars \
      '__hm_new="$HOME/tools"'
    assertFileContains $hmSessVars \
      '__hm_cur="''${TEST3-}"'

    # Multiple blocks must not leak scratch state. Exercise runtime expansion,
    # duplicate/empty candidates, set -u, and re-sourcing under each supported
    # Bourne-style shell.
    # NMT supplies Bash itself. dash and zsh must come from realPkgs because
    # normal test packages are deliberately scrubbed to non-runnable paths.
    for shell in \
      "$BASH" \
      ${realPkgs.dash}/bin/dash \
      ${realPkgs.zsh}/bin/zsh; do
      TERM="dumb" \
        TERMINFO_DIRS="" \
        EMPTY_ENTRY="" \
        HOME="/runtime/home" \
        TEST="baz" \
        "$shell" -uc '
          unset TEST2 TEST3
          . "$1"
          [ "$TEST" = "bar:foo:baz" ] \
            || { echo "TEST after first source: $TEST"; exit 1; }
          [ "$TEST2" = "qux" ] \
            || { echo "TEST2 after first source: $TEST2"; exit 1; }
          [ "$TEST3" = "/runtime/home/tools" ] \
            || { echo "TEST3 after first source: $TEST3"; exit 1; }
          . "$1"
          [ "$TEST" = "bar:foo:baz" ] \
            || { echo "TEST after re-source: $TEST"; exit 1; }
          [ "$TEST2" = "qux" ] \
            || { echo "TEST2 after re-source: $TEST2"; exit 1; }
          [ "$TEST3" = "/runtime/home/tools" ] \
            || { echo "TEST3 after re-source: $TEST3"; exit 1; }
        ' shell "$TESTED/$hmSessVars" \
        || fail "$shell: hm-session-vars.sh search variable semantics broken"
    done
  '';
}
