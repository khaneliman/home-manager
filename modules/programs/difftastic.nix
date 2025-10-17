{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.difftastic;

  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkPackageOption
    types
    ;
in
{
  meta.maintainers = with lib.maintainers; [ khaneliman ];

  imports = [
    (lib.mkChangedOptionModule
      [ "programs" "git" "difftastic" "enable" ]
      [ "programs" "difftastic" "enable" ]
      (
        config:
        builtins.trace
          "programs.git.difftastic.enable has been moved to programs.difftastic.enable and programs.difftastic.enableGitIntegration. Please update your configuration."
          (lib.getAttrFromPath [ "programs" "git" "difftastic" "enable" ] config)
      )
    )
    (lib.mkRenamedOptionModule
      [ "programs" "git" "difftastic" "package" ]
      [ "programs" "difftastic" "package" ]
    )
    (lib.mkRenamedOptionModule
      [ "programs" "git" "difftastic" "enableAsDifftool" ]
      [ "programs" "difftastic" "enableAsDifftool" ]
    )
    (lib.mkRenamedOptionModule
      [ "programs" "git" "difftastic" "options" ]
      [ "programs" "difftastic" "options" ]
    )
  ]
  ++ (
    let
      mkRenamed =
        opt:
        lib.mkRenamedOptionModule
          [ "programs" "git" "difftastic" opt ]
          [ "programs" "git" "difftastic" "options" opt ];
    in
    map mkRenamed [
      "background"
      "color"
      "context"
      "display"
    ]
  )
  ++ [
    (lib.mkRemovedOptionModule [ "programs" "git" "difftastic" "extraArgs" ] ''
      'programs.git.difftastic.extraArgs' has been replaced by 'programs.git.difftastic.options'
    '')
  ];

  options.programs.difftastic = {
    enable = mkEnableOption "difftastic, a structural diff tool";

    package = mkPackageOption pkgs "difftastic" { };

    enableAsDifftool = mkEnableOption "" // {
      description = ''
        Enable the {command}`difftastic` syntax highlighter as a git difftool.
        See <https://github.com/Wilfred/difftastic>.
      '';
    };

    options = mkOption {
      type =
        with types;
        attrsOf (oneOf [
          str
          int
          bool
        ]);
      default = { };
      example = {
        color = "dark";
        sort-path = true;
        tab-width = 8;
      };
      description = "Configuration options for {command}`difftastic`. See {command}`difft --help`";
    };

    enableGitIntegration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable git integration for difftastic.

        When enabled, difftastic will be configured as git's external diff tool.
        When {option}`enableAsDifftool` is enabled, it will be configured as a difftool instead.
      '';
    };
  };

  config =
    let
      oldOptionValue = lib.attrByPath [ "programs" "git" "difftastic" "enable" ] false config;
      oldOptionEnabled = lib.isBool oldOptionValue && oldOptionValue;
    in
    mkMerge [
      (mkIf cfg.enable {
        home.packages = [ cfg.package ];

        # Auto-enable git integration if programs.git.difftastic.enable was set to true
        programs.difftastic.enableGitIntegration = lib.mkIf oldOptionEnabled (lib.mkOverride 1490 true);

        warnings =
          lib.optional
            (cfg.enableGitIntegration && options.programs.difftastic.enableGitIntegration.highestPrio == 1490)
            "`programs.difftastic.enableGitIntegration` automatic enablement is deprecated. Please explicitly set `programs.difftastic.enableGitIntegration = true`.";
      })

      (mkIf (cfg.enable && cfg.enableGitIntegration) {
        programs.git = {
          enable = lib.mkDefault true;
          iniContent =
            let
              difftCommand = "${lib.getExe cfg.package} ${lib.cli.toGNUCommandLineShell { } cfg.options}";
            in
            mkMerge [
              (mkIf (!cfg.enableAsDifftool) {
                diff.external = difftCommand;
              })
              (mkIf cfg.enableAsDifftool {
                diff.tool = lib.mkDefault "difftastic";
                difftool.difftastic.cmd = "${difftCommand} $LOCAL $REMOTE";
              })
            ];
        };
      })
    ];
}
