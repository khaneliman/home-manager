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
#
# You can also run tests as flake checks:
#
#   nix flake check ./tests
#   nix flake check ./tests --keep-going
#
# Or run specific checks:
#
#   nix eval --raw ./tests#checks.x86_64-linux.test-all.drvPath
#   nix build ./tests#checks.x86_64-linux.test-alacritty-empty-settings

{
  description = "Tests of Home Manager for Nix";

  inputs = {
    root.url = "path:../";
    nixpkgs.follows = "root/nixpkgs";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

      # Helper function to generate both packages and checks
      generateTests = system:
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
        in
        testPackages // integrationTestPackages;
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

      # Keep packages for backward compatibility
      packages = forAllSystems generateTests;

      # Add checks attribute that contains the same tests
      checks = forAllSystems generateTests;
    };
}
