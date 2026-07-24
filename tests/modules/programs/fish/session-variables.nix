{ config, ... }:

{
  config = {
    home.sessionVariables = {
      V1 = "v1";
      V2 = "v2-${config.home.sessionVariables.V1}";
    };

    # Exercise the babelfish translation of the idempotent prepend
    # loop generated for search variables.
    home.sessionPath = [
      "/foo/bin"
      ""
      "/bar/bin"
      "/foo/bin"
    ];

    programs.fish.enable = true;

    nmt.script = ''
      assertFileExists home-path/etc/profile.d/hm-session-vars.fish
      assertFileRegex home-path/etc/profile.d/hm-session-vars.fish \
        "set -gx V1 'v1'"
      assertFileRegex home-path/etc/profile.d/hm-session-vars.fish \
        "set -gx V2 'v2-v1'"
      assertFileRegex home-path/etc/profile.d/hm-session-vars.fish \
        "set __hm_new '/foo/bin::/bar/bin:/foo/bin'"
      assertFileRegex home-path/etc/profile.d/hm-session-vars.fish \
        'set -gx PATH'

      fish=${config.programs.fish.package}/bin/fish
      sessionVars=$TESTED/home-path/etc/profile.d/hm-session-vars.fish
      "$fish" --no-config -c '
        set -gx PATH /existing /bar/bin /tail
        source $argv[1]
        set actual (string join : $PATH)
        test "$actual" = "/foo/bin:/existing:/bar/bin:/tail"
        or begin
          echo "after first source: $actual"
          exit 1
        end
        source $argv[1]
        set actual (string join : $PATH)
        test "$actual" = "/foo/bin:/existing:/bar/bin:/tail"
        or begin
          echo "after re-source: $actual"
          exit 1
        end
      ' "$sessionVars" || fail "translated Fish session variables are not idempotent"
    '';
  };
}
