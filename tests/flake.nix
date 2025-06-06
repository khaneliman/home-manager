# This is an internal Nix Flake intended for use when running tests.
#
# You can build all tests or specific tests by running
#
#   nix build --reference-lock-file flake.lock ./tests#test-all
#   nix build --reference-lock-file flake.lock ./tests#test-alacritty-empty-settings
#
# in the Home Manager project root directory.
#
# For parallel test execution, tests are automatically partitioned into groups:
#
#   nix build --reference-lock-file flake.lock ./tests#test-group-0
#   nix build --reference-lock-file flake.lock ./tests#test-group-1
#   ... (up to test-group-10)
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

          # Automatic test partitioning for parallel execution
          testGroups =
            let
              tests = import ./. {
                inherit pkgs;
                enableBig = false;
              };
              
              # Get all test names and sort them for consistent partitioning
              allTestNames = lib.sort (a: b: a < b) (lib.attrNames tests.build);
              
              # Split tests into chunks of reasonable size (~50 tests per group)
              testsPerGroup = 50;
              
              # Custom chunking function since lib.chunksOf may not be available
              chunkList = list: size:
                if list == [] then []
                else 
                  let
                    chunk = lib.take size list;
                    rest = lib.drop size list;
                  in
                  [chunk] ++ chunkList rest size;
              
              chunks = chunkList allTestNames testsPerGroup;
              
              # Create a derivation for each group
              createTestGroup = groupIndex: testNames:
                let
                  groupName = "test-group-${toString groupIndex}";
                  groupTests = map (name: tests.build.${name}) testNames;
                in
                lib.nameValuePair groupName (pkgs.symlinkJoin {
                  name = groupName;
                  paths = groupTests;
                  meta = {
                    description = "Test group ${toString groupIndex} containing ${toString (lib.length testNames)} tests";
                  };
                });
              
            in
            lib.listToAttrs (lib.imap0 createTestGroup chunks);
        in
        testPackages
        // integrationTestPackages  
        // (lib.listToAttrs [
          testAllNoBig
          testAllNoBigIfd
        ])
        // testGroups
      );
    };
}
