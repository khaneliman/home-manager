{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.home-manager.dependencies;

  # A copy of the internal nixvim literalExpressionType
  literalExpressionType = lib.types.mkOptionType {
    name = "literal-expression";
    description = "literal expression";
    descriptionClass = "noun";
    merge = lib.options.mergeEqualOption;
    check = v: v ? _type && (v._type == "literalExpression" || v._type == "literalMD");
  };

  mkDependencyOption = name: properties: {
    enable = lib.mkEnableOption "Add ${name} to dependencies.";

    package =
      lib.mkPackageOption pkgs name properties
      # Handle example manually so that we can embed the original attr-path within
      # the literalExpression object. This simplifies testing the examples.
      // lib.optionalAttrs (builtins.isList properties.example) {
        example = {
          _type = "literalExpression";
          text = "pkgs.${lib.showAttrPath properties.example}";
          path = properties.example;
        };
      }
      // lib.optionalAttrs (literalExpressionType.check properties.example) {
        inherit (properties) example;
      };
  };

  # Motivation:
  # If one were to define `__depPackages.foo.default = "gzip";` in two places (by accident),
  # the module system would merge the two definitions as `["gzip" "gzip"]`.
  #
  # Solution:
  # -> Make attrPathType unique so the option can only be set once.
  attrPathType =
    with types;
    unique { message = "attrPathType must be unique"; } (coercedTo str lib.toList (listOf str));

in
{
  options.home-manager = {
    __depPackages = lib.mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            default = lib.mkOption {
              type = attrPathType;
              description = ''
                Attribute path for this dependency's default package, relative to `pkgs`.
              '';
              example = "git";
            };

            example = lib.mkOption {
              type = types.nullOr (types.either attrPathType literalExpressionType);
              description = ''
                Attribute path for an alternative package that provides dependency, relative to `pkgs`.
              '';
              example = "gitMinimal";
              default = null;
            };
          };
        }
      );
      description = ''
        A set of dependency packages, used internally to construct the `dependencies.<name>` options.
      '';
      default = { };
      example = {
        curl.default = "curl";
        git = {
          default = "git";
          example = "gitMinimal";
        };
      };
      internal = true;
      visible = false;
    };

    dependencies = lib.mapAttrs mkDependencyOption config.home-manager.__depPackages;
  };

  config = {
    home.packages = lib.pipe cfg [
      builtins.attrValues
      (builtins.filter (p: p.enable))
      (builtins.map (p: p.package))
    ];

    home-manager.__depPackages = {
      git = {
        default = "git";
        example = "gitMinimal";
      };
      jq = {
        default = "jq";
      };
    };
  };
}
