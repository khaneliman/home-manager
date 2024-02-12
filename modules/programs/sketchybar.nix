{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkOption
    optionalString
    types
    ;
  cfg = config.programs.sketchybar;

  toSketchybarConfig =
    opts:
    let
      keyValuePairs = lib.mapAttrsToList (p: v: "${p}=${toString v}") opts;
      lastPair = lib.lists.last keyValuePairs;
      linesWithQuotes = map (pair: "${pair} \\\n") (lib.lists.init keyValuePairs);
      lastLine = "${lastPair}";
    in
    lib.concatStrings (linesWithQuotes ++ [ lastLine ]);

  exportVariables =
    variables:
    lib.concatStringsSep "\n" (
      builtins.attrValues (builtins.mapAttrs (name: value: "export ${name}=${value}") variables)
    );

  generateSourceLines =
    sources:
    let
      generateCommand =
        source:
        if (lib.isAttrs source) then
          let
            name = source.name;
            placement = source.placement;
            keyValuePairs = toString (
              lib.mapAttrs (key: value: "${key}=${value}") (
                removeAttrs source [
                  "name"
                  "placement"
                ]
              )
            );
          in
          "sketchybar --add item ${name} ${placement} --set ${name} ${keyValuePairs}"
        else if (lib.isString source || lib.isPath source) then
          "source " + source
        else
          throw "Unsupported source type";
    in
    lib.concatMapStringsSep "\n" (map generateCommand sources);
in
{
  options = {
    programs.sketchybar = {
      enable = lib.mkEnableOption "sketchybar";

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Additional configuration to add to
          {file}`sketchybarrc`.
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.sketchybar;
        defaultText = literalExpression "pkgs.sketchybar";
        example = literalExpression "pkgs.sketchybar";
        description = "The sketchybar package to install";
      };

      sources = mkOption {
        type = with lib.types; listOf (either path str);
        default = [ ];
        example = literalExpression "[]";
        description = "The sources to fetch and install";
      };

      plugins = mkOption {
        type = with lib.types; listOf (either (either path str) attrs);
        default = [ ];
        example = literalExpression ''
          [
                    "script.sh"
                    { name = "script";
                      placement = "right";
                    }
                  ]'';
        description = "The sources to fetch and install";
      };

      variables = mkOption {
        type = types.attrs;
        default = { };
        example = literalExpression ''
          {
            TEXT = "0xffcad3f5";
          }
        '';
        description = lib.mdDoc ''
          Key/Value pairs of environment variables to export via the configuration file.
        '';
      };

      config = mkOption {
        description = lib.mdDoc ''
          Sketchybar config options to generate sketchybarrc.
        '';
        type = types.submodule {
          options = {
            bar = mkOption {
              type = types.attrs;
              default = { };
              example = literalExpression ''
                {
                  blur_radius         = 30;
                  border_width        = 2;
                  color               = "red";
                  corner_radius       = 9;
                  height              = 40;
                  margin              = 10;
                  notch_width         = 0;
                  padding_left        = 18;
                  padding_right       = 10;
                  position            = top;
                  shadow              = on;
                  sticky              = on;
                  topmost             = off;
                  y_offset            = 10;
                }
              '';
              description = lib.mdDoc ''
                Key/Value pairs to pass to sketchybar --bar command, via the configuration file.
              '';
            };

            defaults = mkOption {
              type = types.attrs;
              default = { };
              example = literalExpression ''
                {
                  "icon.color" = "$TEXT";
                  "icon.font" = "$NERD_FONT:Bold:16.0";
                  "icon.padding_left" = "$PADDINGS";
                  "icon.padding_right" = "$PADDINGS";
                  "label.color" = "$TEXT";
                  "label.font" = "$FONT:Semibold:13.0";
                  "label.padding_left" = "$PADDINGS";
                  "label.padding_right" = "$PADDINGS";
                  "background.corner_radius" = 9;
                  "background.height" = 30;
                  "background.padding_left" = "$PADDINGS";
                  "background.padding_right" = "$PADDINGS";
                  "popup.height" = 30;
                  "popup.horizontal" = "false";
                  "popup.background.border_color" = "$BLUE";
                  "popup.background.border_width" = 2;
                  "popup.background.color" = "$MANTLE";
                  "popup.background.corner_radius" = 11;
                  "popup.background.shadow.drawing" = "on";
                }
              '';
              description = lib.mdDoc ''
                Key/Value pairs to pass to sketchybar --defaults command, via the configuration file.
              '';
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."sketchybar/sketchybarrc".source = pkgs.writeShellScript "sketchybarrc" (
      "\n"
      + optionalString (cfg.sources != [ ]) "${generateSourceLines cfg.sources}\n\n"
      + optionalString (cfg.variables != { }) "${exportVariables cfg.variables}\n\n"
      + optionalString (
        cfg.config.bar != { }
      ) "sketchybar --bar \\\n${toSketchybarConfig cfg.config.bar}\n\n"
      + optionalString (
        cfg.config.defaults != { }
      ) "sketchybar --default \\\n${toSketchybarConfig cfg.config.defaults}\n\n"
      + optionalString (cfg.plugins != [ ]) "\n\n${generateSourceLines cfg.plugins}\n\n"
      + optionalString (cfg.extraConfig != "") ("\n\n" + cfg.extraConfig + "\n\n")
      + "\n\nsketchybar --update"
    );
  };
}
