{
  config,
  lib,
  pkgs,
  ...
}:
let
  legacyDefault = lib.hm.deprecations.mkStateVersionOptionDefault {
    stateVersion = "25.11";
    since = "26.05";
    option = "test.values.legacy";
    legacyValue = "legacy";
    defaultValue = "new";
  };

  newDefault = lib.hm.deprecations.mkStateVersionOptionDefault {
    stateVersion = "26.05";
    since = "26.05";
    option = "test.values.new";
    legacyValue = "legacy";
    defaultValue = "new";
  };
in
{
  options.test.values = {
    legacy = lib.mkOption {
      type = lib.types.str;
      inherit (legacyDefault) default;
    };

    new = lib.mkOption {
      type = lib.types.str;
      inherit (newDefault) default;
    };
  };

  config = {
    home.file."result.txt".text = ''
      legacy=${config.test.values.legacy}
      new=${config.test.values.new}
    '';

    test.asserts.evalWarnings.expected = [
      ''
        The default value of `test.values.legacy` has changed from `"legacy"` to `"new"`.
        You are currently using the legacy default (`"legacy"`) because `home.stateVersion` is less than "26.05".
        To silence this warning and keep legacy behavior, set:
          test.values.legacy = "legacy";
        To adopt the new default behavior, set:
          test.values.legacy = "new";
      ''
    ];

    nmt.script = ''
      assertFileContent home-files/result.txt ${pkgs.writeText "state-version-option-default.txt" ''
        legacy=legacy
        new=new
      ''}
    '';
  };
}
