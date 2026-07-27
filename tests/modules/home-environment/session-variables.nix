{ config, ... }:

{
  home.sessionVariables = {
    V1 = "v1";
    V2 = "v2-${config.home.sessionVariables.V1}";
    IS_EMPTY = "";
    IS_NULL = null;
    IS_TRUE = true;
    IS_FALSE = false;
  };

  nmt.script = ''
    sessionVars=home-path/etc/profile.d/hm-session-vars.sh
    assertFileExists "$sessionVars"
    assertFileContains "$sessionVars" 'case " ''${__HM_SESS_VARS_SKIP-} " in'
    assertFileNotRegex "$sessionVars" 'export IS_NULL='

    (
      export V1=stale V2=stale
      export __HM_SESS_VARS_SKIP=" V1 "
      unset __HM_SESS_VARS_SOURCED
      . "$TESTED/$sessionVars"
      [ "$V1" = stale ] || exit 1
      [ "$V2" = v2-v1 ] || exit 1
      [ "$IS_EMPTY" = "" ] || exit 1
      [ "$IS_FALSE" = false ] || exit 1
      [ "$IS_TRUE" = true ] || exit 1
    ) || fail "session variable refresh or skip manifest failed"
  '';
}
