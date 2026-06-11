{ lib, pkgs, ... }:

{
  nmt.script =
    let
      stateVersionEval = lib.evalModules {
        modules = [
          {
            options.home.stateVersion = lib.mkOption {
              type = lib.types.str;
            };

            config.home.stateVersion = "25.11";
          }
        ];
      };

      stateVersionDefault = lib.hm.deprecations.mkStateVersionOptionDefault {
        stateVersion = stateVersionEval.config.home.stateVersion;
        since = "26.05";
        optionPath = [
          "programs"
          "example"
          "enable"
        ];
        legacy.value = false;
        current.value = true;
        inherit (stateVersionEval) options;
      };

      expected = pkgs.writeText "deprecation-warnings.expected" ''
        Using `programs.example.settings` as a list is deprecated and will be
        removed in a future release. Please use `programs.example.settings.items` instead.

        Move list entries under `settings.items`.

        The value "kde6" for `qt.platformTheme.name` is deprecated and will be
        removed in a future release. Please use "kde" instead.

        The default value of `programs.example.enable` has changed from `false` to `true`.
        You are currently using the legacy default (`false`) because `home.stateVersion` is less than "26.05".
        To silence this warning and keep legacy behavior, set:
          programs.example.enable = false;
        To adopt the new default behavior, set:
          programs.example.enable = true;
      '';

      actual = pkgs.writeText "deprecation-warnings.actual" (
        lib.hm.deprecations.mkDeprecatedOptionValueWarning {
          option = [
            "programs"
            "example"
            "settings"
          ];
          old = "a list";
          replacement = "`programs.example.settings.items`";
          details = "Move list entries under `settings.items`.";
          files = [ "<unknown-file>" ];
        }
        + "\n"
        + lib.hm.deprecations.mkDeprecatedOptionValueRenameWarning {
          option = [
            "qt"
            "platformTheme"
            "name"
          ];
          old = ''"kde6"'';
          replacement = ''"kde"'';
        }
        + "\n"
        + stateVersionDefault.warning
      );
    in
    ''
      assertFileContent ${actual} ${expected}
    '';
}
