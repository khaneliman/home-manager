{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    hm
    types
    ;

  # Test various flexible content configurations
  testResults = {
    # Test pathOrLines type
    pathOrLinesString = hm.types.pathOrLines.check "simple string content";
    pathOrLinesPath = hm.types.pathOrLines.check ./default.nix;
    pathOrLinesInvalid = hm.types.pathOrLines.check 123;

    # Test attrsOfPathOrLines type
    attrsOfPathOrLines = hm.types.attrsOfPathOrLines.check {
      config1 = "inline content";
      config2 = ./default.nix;
    };

    # Test directoryOrFileContent type
    directoryOrFileString = hm.types.directoryOrFileContent.check "inline text";
    directoryOrFileAttr = hm.types.directoryOrFileContent.check {
      source = ./default.nix;
      recursive = true;
    };

    # Test ultraFlexibleContent type
    ultraFlexString = hm.types.ultraFlexibleContent.check "simple string";
    ultraFlexPath = hm.types.ultraFlexibleContent.check ./default.nix;
    ultraFlexAttr = hm.types.ultraFlexibleContent.check {
      source = ./default.nix;
      recursive = true;
      text = null;
    };
    ultraFlexAttrsOf = hm.types.ultraFlexibleContent.check {
      file1 = "content1";
      file2 = ./default.nix;
      file3 = {
        source = ./default.nix;
        recursive = false;
      };
    };

    # Test settingsContent type
    settingsString = hm.types.settingsContent.check "simple string";
    settingsPath = hm.types.settingsContent.check ./default.nix;
    settingsSubmodule = hm.types.settingsContent.check {
      source = ./default.nix;
      text = null;
      recursive = true;
      settings = {
        config1 = "inline";
        config2 = ./default.nix;
      };
    };

    # Test helper functions (just check they don't error)
    normalizeString = builtins.isAttrs (hm.types.normalizeFlexibleContent "test content");
    normalizePath = builtins.isAttrs (hm.types.normalizeFlexibleContent ./default.nix);
    normalizeAttr = builtins.isAttrs (
      hm.types.normalizeFlexibleContent {
        source = ./default.nix;
        recursive = true;
      }
    );
    normalizeSettings = builtins.isAttrs (
      hm.types.normalizeFlexibleContent {
        file1 = "content";
        file2 = ./default.nix;
      }
    );
  };

  # Convert test results to readable format
  resultText = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "${name}: ${toString value}") testResults
  );

in
{
  config = {
    home.file."flexible-content-test-results.txt".text = resultText;

    nmt.script = ''
      # Verify that basic type checking works as expected
      assertFileContent \
        home-files/flexible-content-test-results.txt \
        ${./flexible-content-result.txt}
    '';
  };
}
