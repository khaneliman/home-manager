{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.git-lfs;

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  meta.maintainers = with lib.maintainers; [ khaneliman ];

  imports = [
    (lib.mkChangedOptionModule [ "programs" "git" "lfs" "enable" ] [ "programs" "git-lfs" "enable" ] (
      config:
      builtins.trace
        "programs.git.lfs.enable has been moved to programs.git-lfs.enable and programs.git-lfs.enableGitIntegration. Please update your configuration."
        (lib.getAttrFromPath [ "programs" "git" "lfs" "enable" ] config)
    ))
    (lib.mkRenamedOptionModule
      [ "programs" "git" "lfs" "skipSmudge" ]
      [ "programs" "git-lfs" "skipSmudge" ]
    )
  ];

  options.programs.git-lfs = {
    enable = mkEnableOption "Git Large File Storage";

    skipSmudge = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Skip automatic downloading of objects on clone or pull.
        This requires a manual {command}`git lfs pull`
        every time a new commit is checked out on your repository.
      '';
    };

    enableGitIntegration = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable git integration for git-lfs.

        When enabled, git-lfs will be configured as a git filter.
      '';
    };
  };

  config =
    let
      oldOptionValue = lib.attrByPath [ "programs" "git" "lfs" "enable" ] false config;
      oldOptionEnabled = lib.isBool oldOptionValue && oldOptionValue;
    in
    lib.mkMerge [
      (mkIf cfg.enable {
        home.packages = [ pkgs.git-lfs ];

        # Auto-enable git integration if programs.git.lfs.enable was set to true
        programs.git-lfs.enableGitIntegration = lib.mkIf oldOptionEnabled (lib.mkOverride 1490 true);

        warnings =
          lib.optional
            (cfg.enableGitIntegration && options.programs.git-lfs.enableGitIntegration.highestPrio == 1490)
            "`programs.git-lfs.enableGitIntegration` automatic enablement is deprecated. Please explicitly set `programs.git-lfs.enableGitIntegration = true`.";
      })

      (mkIf (cfg.enable && cfg.enableGitIntegration) {
        programs.git = {
          enable = lib.mkDefault true;
          iniContent.filter.lfs =
            let
              skipArg = lib.optional cfg.skipSmudge "--skip";
            in
            {
              clean = "git-lfs clean -- %f";
              process = lib.concatStringsSep " " (
                [
                  "git-lfs"
                  "filter-process"
                ]
                ++ skipArg
              );
              required = true;
              smudge = lib.concatStringsSep " " (
                [
                  "git-lfs"
                  "smudge"
                ]
                ++ skipArg
                ++ [
                  "--"
                  "%f"
                ]
              );
            };
        };
      })
    ];
}
