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

  definitionFiles =
    option: value:
    lib.unique (
      lib.concatMap (
        definition: lib.optionals (lib.any (entry: entry == value) definition.value) [ definition.file ]
      ) option.definitionsWithLocations
    );

  actual = pkgs.writeText "diagnostics-definition-files.actual" (
    lib.concatStringsSep "\n---\n" (
      (lib.hm.diagnostics.formatWarnings eval.options.warnings eval.config.warnings)
      ++ (lib.hm.diagnostics.collectFailedAssertions eval.options eval.config.assertions)
    )
  );

  expected = pkgs.writeText "diagnostics-definition-files.expected" (
    lib.concatStringsSep "\n---\n" [
      ''
        ${plainWarning}

        Warning defined in ${lib.showFiles (definitionFiles eval.options.warnings plainWarning)}.''
      ''
        ${lib.removeSuffix "\n" platformAssertion.message}

        Assertion defined in ${lib.showFiles eval.options.programs.example.enable.files}.''
      ''
        ${plainAssertion.message}

        Assertion defined in ${lib.showFiles (definitionFiles eval.options.assertions plainAssertion)}.''
    ]
  );
in
{
  nmt.script = ''
    assertFileContent ${actual} ${expected}
  '';
}
