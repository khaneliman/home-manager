{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;

  cfg = config.programs.gitui;

in
{
  meta.maintainers = [ lib.hm.maintainers.mifom ];

  options.programs.gitui = {
    enable = lib.mkEnableOption "gitui, blazing fast terminal-ui for git written in rust";

    package = lib.mkPackageOption pkgs "gitui" { };

    keyConfig = mkOption {
      type = lib.hm.types.fileContent;
      default = "";
      example = ''
        exit: Some(( code: Char('c'), modifiers: ( bits: 2,),)),
        quit: Some(( code: Char('q'), modifiers: ( bits: 0,),)),
        exit_popup: Some(( code: Esc, modifiers: ( bits: 0,),)),
      '';
      description = ''
        Key config in Ron file format. This is written to
        {file}`$XDG_CONFIG_HOME/gitui/key_config.ron`.
      '';
    };

    theme = mkOption {
      type = lib.hm.types.fileContent;
      default = ''
        (
          selected_tab: Reset,
          command_fg: White,
          selection_bg: Blue,
          selection_fg: White,
          cmdbar_bg: Blue,
          cmdbar_extra_lines_bg: Blue,
          disabled_fg: DarkGray,
          diff_line_add: Green,
          diff_line_delete: Red,
          diff_file_added: LightGreen,
          diff_file_removed: LightRed,
          diff_file_moved: LightMagenta,
          diff_file_modified: Yellow,
          commit_hash: Magenta,
          commit_time: LightCyan,
          commit_author: Green,
          danger_fg: Red,
          push_gauge_bg: Blue,
          push_gauge_fg: Reset,
          tag_fg: LightMagenta,
          branch_fg: LightYellow,
        )
      '';
      description = ''
        Theme in Ron file format. This is written to
        {file}`$XDG_CONFIG_HOME/gitui/theme.ron`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."gitui/theme.ron" = cfg.theme;
    xdg.configFile."gitui/key_bindings.ron" = cfg.keyConfig;
  };
}
