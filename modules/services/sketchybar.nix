{ config, lib, pkgs, ... }:
let cfg = config.services.sketchybar;
in {
  meta.maintainers = [ lib.maintainers.khaneliman ];

  options.services.sketchybar = {
    enable = lib.mkEnableOption "sketchybar";

    package = lib.mkPackageOption pkgs "sketchybar" { };

    errorLogFile = lib.mkOption {
      type = with lib.types; nullOr (either path str);
      defaultText = lib.literalExpression
        "\${config.home.homeDirectory}/Library/Logs/sketchybar/err.log";
      example = "/Users/khaneliman/Library/Logs/sketchybar.log";
      description = "Absolute path to log all stderr output.";
    };

    outLogFile = lib.mkOption {
      type = with lib.types; nullOr (either path str);
      defaultText = lib.literalExpression
        "\${config.home.homeDirectory}/Library/Logs/sketchybar/out.log";
      example = "/Users/khaneliman/Library/Logs/sketchybar.log";
      description = "Absolute path to log all stdout output.";
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
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.sketchybar" pkgs
        lib.platforms.darwin)
    ];

    home.packages = [ cfg.package ];

    launchd.agents.sketchybar = {
      enable = true;
      config = {
        Program = lib.getExe cfg.package;
        ProcessType = "Interactive";
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = cfg.errorLogFile;
        StandardOutPath = cfg.outLogFile;
        EnvironmentVariables = {
          PATH = (concatMapStringsSep ":" (p: "${p}/bin") ([cfg.package] ++ cfg.extraPackages));
        };
      };
    };

    services.sketchybar = {
      errorLogFile = lib.mkOptionDefault
        "${config.home.homeDirectory}/Library/Logs/sketchybar/sketchybar.err.log";
      outLogFile = lib.mkOptionDefault
        "${config.home.homeDirectory}/Library/Logs/sketchybar/sketchybar.out.log";
    };

    xdg.configFile."sketchybar/sketchybarrc".source = lib.mkIf (cfg.config != "") pkgs.writeScript "sketchybarrc" cfg.config;
  };
}
