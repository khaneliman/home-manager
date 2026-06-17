{
  configuration,
  pkgs,
  lib ? pkgs.lib,
  minimal ? false,
  # Whether to check that each option has a matching declaration.
  check ? true,
  # Extra arguments passed to specialArgs.
  extraSpecialArgs ? { },
}:

let

  extendedLib = import ./lib/stdlib-extended.nix lib;

  collectFailed =
    raw: extendedLib.hm.diagnostics.collectFailedAssertions raw.options raw.config.assertions;

  showWarnings =
    raw: res:
    let
      formatted = extendedLib.hm.diagnostics.formatWarnings raw.options raw.config.warnings;
      f = w: x: builtins.trace " [1;31mwarning: ${w} [0m" x;
    in
    lib.foldr f res formatted;

  hmModules = import ./modules.nix {
    inherit check pkgs minimal;
    lib = extendedLib;
  };

  rawModule = extendedLib.evalModules {
    modules = [ configuration ] ++ hmModules;
    class = "homeManager";
    specialArgs = {
      modulesPath = toString ./.;
    }
    // extraSpecialArgs;
  };

  moduleChecks =
    raw:
    showWarnings raw (
      let
        failed = collectFailed raw;
        failedStr = lib.concatStringsSep "\n" (map (x: "- ${x}") failed);
      in
      if failed == [ ] then
        raw
      else
        throw ''

          Failed assertions:
          ${failedStr}''
    );

  withExtraAttrs =
    rawModule:
    let
      module = moduleChecks rawModule;
    in
    module
    // {
      inherit (module.config.home) activationPackage;

      # For backwards compatibility. Please use activationPackage instead.
      activation-script = module.config.home.activationPackage;

      newsDisplay = rawModule.config.news.display;
      newsEntries = lib.sort (a: b: a.time > b.time) (
        lib.filter (a: a.condition) rawModule.config.news.entries
      );

      inherit (module._module.args) pkgs;

      extendModules = args: withExtraAttrs (rawModule.extendModules args);
    };
in
withExtraAttrs rawModule
