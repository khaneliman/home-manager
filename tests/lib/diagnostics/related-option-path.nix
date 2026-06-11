{ lib, pkgs, ... }:

let
  fakePkgs.stdenv.hostPlatform.system = "x86_64-darwin";
  systemdAssertion = lib.hm.assertions.assertPlatform {
    module = "systemd";
    optionPath = [
      "systemd"
      "user"
    ];
  } fakePkgs [ "x86_64-linux" ];

  eval = lib.evalModules {
    modules = [
      ./options.nix
      ./systemd-platform-assertion.nix
      ./systemd-platform-user.nix
    ];
  };

  actual = pkgs.writeText "diagnostics-related-option-path.actual" (
    lib.concatStringsSep "\n---\n" (
      lib.hm.diagnostics.collectFailedAssertions eval.options eval.config.assertions
    )
  );

  expected = pkgs.writeText "diagnostics-related-option-path.expected" ''
    ${lib.removeSuffix "\n" systemdAssertion.message}

    Assertion defined in ${lib.showFiles eval.options.systemd.user.enable.files}.'';
in
{
  nmt.script = ''
    assertFileContent ${actual} ${expected}
  '';
}
