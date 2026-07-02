{ pkgs, ... }:

let
  hmLib = import ../../../modules/lib/stdlib-extended.nix pkgs.lib;

  eval = hmLib.evalModules {
    modules = [
      ../../../modules/misc/assertions.nix
      ./options.nix
      ./example-enable.nix
      ./related-warning.nix
      ./related-warning-dotted.nix
      ./plain-warning.nix
      ./unmatched-warning.nix
      ./related-assertion.nix
      ./plain-assertion.nix
      ./platform-assertion.nix
    ];
  };

  exampleEnableFiles = eval.options.programs.example.enable.files;

  platformAssertion = hmLib.hm.assertions.assertPlatform "programs.example" {
    stdenv.hostPlatform.system = "x86_64-linux";
  } [ "x86_64-darwin" ];

  actual = pkgs.writeText "diagnostics-related-options.actual" (
    hmLib.concatStringsSep "\n---\n" (
      (hmLib.hm.diagnostics.formatWarnings eval.options eval.config.warnings)
      ++ (hmLib.hm.diagnostics.collectFailedAssertions eval.options eval.config.assertions)
    )
  );

  expected = pkgs.writeText "diagnostics-related-options.expected" (
    hmLib.concatStringsSep "\n---\n" [
      # (c) relatedOptions that never resolve to a user definition leave the
      # message unchanged.
      "no related option was ever defined"
      # (b) plain string warning passes through unchanged.
      "plain warning, unchanged"
      # (d) relatedOptions given as a dot-separated string behaves like the
      # list form.
      ''
        example is deprecated (dotted path)

        Caused by definitions in ${hmLib.showFiles exampleEnableFiles}.''
      # (a) structured warning with relatedOptions resolving to a definition file.
      ''
        example is deprecated

        Caused by definitions in ${hmLib.showFiles exampleEnableFiles}.''
      # (f) assertPlatform's relatedOptions default to the module's `enable`
      # option, so the failure points at the file that turned it on.
      ''
        ${hmLib.removeSuffix "\n" platformAssertion.message}

        Caused by definitions in ${hmLib.showFiles exampleEnableFiles}.''
      # (e) failed assertion without relatedOptions is unchanged.
      "plain assertion failure, unchanged"
      # (e) failed assertion with relatedOptions gets the suffix.
      ''
        related assertion failure

        Caused by definitions in ${hmLib.showFiles exampleEnableFiles}.''
    ]
  );
in
{
  nmt.script = ''
    assertFileContent ${actual} ${expected}
  '';
}
