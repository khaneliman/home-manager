{ lib, pkgs, ... }:

let
  eval = lib.evalModules {
    modules = [
      ./options.nix
      ./platform-user.nix
    ];
  };

  warning = "example warning";

  actual = pkgs.writeText "diagnostics-warning-for-option.actual" (
    lib.hm.diagnostics.warningForOption eval.options [
      "programs"
      "example"
      "enable"
    ] warning
  );

  expected = pkgs.writeText "diagnostics-warning-for-option.expected" ''
    ${warning}

    Warning defined in ${lib.showFiles eval.options.programs.example.enable.files}.'';
in
{
  nmt.script = ''
    assertFileContent ${actual} ${expected}
  '';
}
