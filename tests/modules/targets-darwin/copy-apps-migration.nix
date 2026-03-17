{ pkgs, ... }:
let
  darwinTestApp = pkgs.runCommandLocal "target-darwin-copy-apps-migration-app" { } ''
    mkdir -p $out/Applications/Example.app
    touch $out/Applications/Example.app/example
  '';
in
{
  config = {
    home.stateVersion = "25.11";
    home.packages = [ darwinTestApp ];

    nmt.script = ''
      assertFileRegex activate 'Activating copyApps'
      assertFileRegex activate 'tmpTarget="\$\(mktemp -d "\$targetParent/\.\$\{targetName\}\.tmp\.XXXXXX"\)"'
      assertFileRegex activate 'run .*rsync.* "\$tmpTarget/"'
      assertFileRegex activate 'run mv "\$tmpTarget" "\$targetFolder"'

      if grep -q 'Activating checkAppManagementPermission' activate; then
        fail "unexpected App Management preflight in activate script"
      fi

      if grep -q 'Activating cleanupLegacyAppLinks' activate; then
        fail "unexpected legacy cleanup step in activate script"
      fi
    '';
  };
}
