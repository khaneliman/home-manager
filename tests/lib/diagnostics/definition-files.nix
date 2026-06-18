{ lib, pkgs, ... }:

let
  plainWarning = "plain warning";
  plainAssertion = {
    assertion = false;
    message = "plain failure";
  };
  fakePkgs.stdenv.hostPlatform.system = "x86_64-darwin";
  platformAssertion = lib.hm.assertions.assertPlatform "programs.example" fakePkgs [ "x86_64-linux" ];

  eval = lib.evalModules {
    modules = [
      ./options.nix
      ./plain-assertion.nix
      ./platform-assertion.nix
      ./platform-user.nix
      ./warning.nix
    ];
  };

  actual = pkgs.writeText "diagnostics-definition-files.actual" (
    lib.concatStringsSep "\n---\n" (
      (lib.hm.diagnostics.formatWarnings eval.options eval.config.warnings)
      ++ (lib.hm.diagnostics.collectFailedAssertions eval.options eval.config.assertions)
    )
  );

  warningFile =
    let
      matching = lib.filter (
        def: lib.any (val: toString val == toString plainWarning) def.value
      ) eval.options.warnings.definitionsWithLocations;
    in
    (lib.head matching).file;

  plainAssertionFile =
    let
      matching = lib.filter (
        def: lib.any (val: val.message or "" == plainAssertion.message) def.value
      ) eval.options.assertions.definitionsWithLocations;
    in
    (lib.head matching).file;

  expected = pkgs.writeText "diagnostics-definition-files.expected" (
    lib.concatStringsSep "\n---\n" [
      ''
        ${plainWarning}

        Warning defined in ${lib.showFiles [ warningFile ]}.''
      ''
        ${lib.removeSuffix "\n" platformAssertion.message}

        Assertion defined in ${lib.showFiles eval.options.programs.example.enable.files}.''
      ''
        ${plainAssertion.message}

        Assertion defined in ${lib.showFiles [ plainAssertionFile ]}.''
    ]
  );
in
{
  nmt.script = ''
    assertFileContent ${actual} ${expected}
  '';
}
