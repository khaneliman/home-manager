{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.services.sketchybar;
in
{
  meta.maintainers = [ lib.maintainers.khaneliman ];

  options.services.sketchybar = {
    enable = lib.mkEnableOption "sketchybar";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.sketchybar;
      defaultText = lib.literalExpression "pkgs.sketchybar";
      description = "The sketchybar package to use.";
    };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.jq ]";
      description = ''
        Extra packages to add to PATH.
      '';
    };

    config = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        sketchybar --bar height=24
        sketchybar --update
        echo "sketchybar configuration loaded.."
      '';
      description = ''
        Contents of sketchybar's configuration file. If empty (the default), the configuration file won't be managed.

        See [documentation](https://felixkratz.github.io/SketchyBar/)
        and [example](https://github.com/FelixKratz/SketchyBar/blob/master/sketchybarrc).
      '';
    };

    logFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = "/var/tmp/sketchybar.log";
      example = "/Users/khaneliman/Library/Logs/sketchybar.log";
      description = "Absolute path to log all stderr and stdout";
    };

  };

  config = mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.sketchybar" pkgs lib.platforms.darwin)
    ];

    home.packages = [ cfg.package ];

    launchd.agents.sketchybar = {
      enable = true;
      config = {
        ProgramArguments =
          [
            (lib.getExe cfg.package)
          ]
          ++ lib.optionals (cfg.config != "") [
            "--config"
            "${pkgs.writeScript "sketchybarrc" cfg.config}"
          ];

        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };

        StandardErrorPath = cfg.logFile;
        StandardOutPath = cfg.logFile;
      };
    };
  };
}
