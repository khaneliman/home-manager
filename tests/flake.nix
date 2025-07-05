# This is an internal Nix Flake intended for use when running tests.
#
# You can build all tests or specific tests by running
#
#   nix build --reference-lock-file flake.lock ./tests#test-all
#   nix build --reference-lock-file flake.lock ./tests#test-alacritty-empty-settings
#
# in the Home Manager project root directory.
#
# Similarly for integration tests
#
#   nix build --reference-lock-file flake.lock ./tests#integration-test-all
#   nix build --reference-lock-file flake.lock ./tests#integration-test-standalone-standard-basics

{
  description = "Tests of Home Manager for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tests = import ./. { inherit pkgs; };
        in
        tests.run
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;

          testPackages =
            let
              tests = import ./. { inherit pkgs; };
              renameTestPkg = n: lib.nameValuePair "test-${n}";
            in
            lib.mapAttrs' renameTestPkg tests.build;

          integrationTestPackages =
            let
              tests = import ./integration { inherit pkgs; };
              renameTestPkg = n: lib.nameValuePair "integration-test-${n}";
            in
            lib.mapAttrs' renameTestPkg tests;

          testAllNoBig =
            let
              tests = import ./. {
                inherit pkgs;
                enableBig = false;
              };
            in
            lib.nameValuePair "test-all-no-big" tests.build.all;

          testAllNoBigIfd =
            let
              tests = import ./. {
                inherit pkgs;
                enableBig = false;
                enableLegacyIfd = true;
              };
            in
            lib.nameValuePair "test-all-no-big-ifd" tests.build.all;

          # Create chunked test packages for better CI parallelization
          testChunks =
            let
              tests = import ./. {
                inherit pkgs;
                enableBig = false;
              };
              allTests = lib.attrNames tests.build;
              # Remove 'all' from the test list as it's a meta-package
              filteredTests = lib.filter (name: name != "all") allTests;
              # Auto-calculate optimal chunk count based on test count
              # Target ~200-300 tests per chunk for optimal performance
              targetTestsPerChunk = 250;
              numChunks = lib.max 1 (
                builtins.ceil ((builtins.length filteredTests) / (targetTestsPerChunk * 1.0))
              );
              chunkSize = builtins.ceil ((builtins.length filteredTests) / (numChunks * 1.0));

              makeChunk =
                chunkNum: testList:
                let
                  start = (chunkNum - 1) * chunkSize;
                  end = lib.min (start + chunkSize) (builtins.length testList);
                  chunkTests = lib.sublist start (end - start) testList;
                  chunkAttrs = lib.genAttrs chunkTests (name: tests.build.${name});
                in
                pkgs.symlinkJoin {
                  name = "test-chunk-${toString chunkNum}";
                  paths = lib.attrValues chunkAttrs;
                };
            in
            lib.listToAttrs (
              lib.genList (
                i: lib.nameValuePair "test-chunk-${toString (i + 1)}" (makeChunk (i + 1) filteredTests)
              ) numChunks
            )
            // {
              # Verification: ensure all tests are covered
              coverage-check = pkgs.writeTextFile {
                name = "test-coverage-verification";
                text =
                  let
                    # Get all tests assigned to chunks (using exact same logic as makeChunk)
                    allChunkTests = lib.concatLists (
                      lib.genList (
                        i:
                        let
                          chunkNum = i + 1;
                          start = (chunkNum - 1) * chunkSize;
                          end = lib.min (start + chunkSize) (builtins.length filteredTests);
                        in
                        lib.sublist start (end - start) filteredTests
                      ) numChunks
                    );

                    # Verify coverage
                    missingTests = lib.subtractLists allChunkTests filteredTests;
                    duplicateTests = lib.subtractLists (lib.unique allChunkTests) allChunkTests;
                    duplicateCount = builtins.length duplicateTests;

                    coverageReport = {
                      totalTests = builtins.length filteredTests;
                      numChunks = numChunks;
                      chunkSize = chunkSize;
                      assignedTests = builtins.length allChunkTests;
                      missingTests = missingTests;
                      duplicateTests = duplicateCount;
                      allTestsCovered = missingTests == [ ] && duplicateCount == 0;
                    };
                  in
                  builtins.toJSON coverageReport;
              };
            };
        in
        testPackages
        // integrationTestPackages
        // testChunks
        // (lib.listToAttrs [
          testAllNoBig
          testAllNoBigIfd
        ])
      );
    };
}
