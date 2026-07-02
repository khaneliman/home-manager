{ lib, ... }:
let
  # An option path, either as a list of segments or a dot-separated string.
  optionPathType = lib.types.coercedTo lib.types.str (lib.splitString ".") (
    lib.types.listOf lib.types.str
  );

  warningType = lib.types.submodule {
    options = {
      message = lib.mkOption {
        type = lib.types.str;
        description = "The warning message.";
      };

      relatedOptions = lib.mkOption {
        type = lib.types.listOf optionPathType;
        default = [ ];
        description = ''
          Options related to this warning. The files in which the user
          defined these options are appended to the warning message so the
          warning points at the configuration that needs to change.
        '';
      };
    };
  };
in
{
  options = {
    assertions = lib.mkOption {
      type = lib.types.listOf lib.types.unspecified;
      internal = true;
      default = [ ];
      example = [
        {
          assertion = false;
          message = "you can't enable this for that reason";
        }
      ];
      description = ''
        This option allows modules to express conditions that must
        hold for the evaluation of the configuration to succeed,
        along with associated error messages for the user.

        An assertion may optionally carry a `relatedOptions` list of
        option paths; the files defining those options are appended to
        the failure message.
      '';
    };

    warnings = lib.mkOption {
      internal = true;
      default = [ ];
      type = lib.types.listOf (
        lib.types.coercedTo lib.types.str (message: { inherit message; }) warningType
      );
      example = [ "The `foo' service is deprecated and will go away soon!" ];
      description = ''
        This option allows modules to show warnings to users during
        the evaluation of the configuration.

        A warning may be given as a plain string or as an attribute set
        with `message` and `relatedOptions`; the files defining the
        related options are appended to the displayed warning.
      '';
    };
  };
}
