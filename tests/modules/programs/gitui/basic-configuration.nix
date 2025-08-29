{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.gitui = {
    enable = true;
    theme = ''
      (
          selected_tab: Some(Reset),
          command_fg: Some(White),
          selection_bg: Some(Blue),
          selection_fg: Some(White),
          cmdbar_bg: Some(Blue),
          cmdbar_extra_lines_bg: Some(Blue),
          disabled_fg: Some(DarkGray),
          diff_line_add: Some(Green),
          diff_line_delete: Some(Red),
          diff_file_added: Some(LightGreen),
          diff_file_removed: Some(LightRed),
          diff_file_moved: Some(LightMagenta),
          diff_file_modified: Some(Yellow),
          commit_hash: Some(Magenta),
          commit_time: Some(LightCyan),
          commit_author: Some(Green),
          danger_fg: Some(Red),
          push_gauge_bg: Some(Blue),
          push_gauge_fg: Some(Reset),
          tag_fg: Some(LightMagenta),
          branch_fg: Some(LightYellow)
      )
    '';
    keyConfig = ''
      (
          focus_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
          focus_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
          focus_up: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
          focus_down: Some(( code: Char('j'), modifiers: ( bits: 0,),)),
      )
    '';
  };

  nmt.script = ''
    assertFileExists home-files/.config/gitui/theme.ron
    assertFileExists home-files/.config/gitui/key_bindings.ron

    # Test theme content
    assertFileContent home-files/.config/gitui/theme.ron ${pkgs.writeText "expected-theme.ron" ''
      (
          selected_tab: Some(Reset),
          command_fg: Some(White),
          selection_bg: Some(Blue),
          selection_fg: Some(White),
          cmdbar_bg: Some(Blue),
          cmdbar_extra_lines_bg: Some(Blue),
          disabled_fg: Some(DarkGray),
          diff_line_add: Some(Green),
          diff_line_delete: Some(Red),
          diff_file_added: Some(LightGreen),
          diff_file_removed: Some(LightRed),
          diff_file_moved: Some(LightMagenta),
          diff_file_modified: Some(Yellow),
          commit_hash: Some(Magenta),
          commit_time: Some(LightCyan),
          commit_author: Some(Green),
          danger_fg: Some(Red),
          push_gauge_bg: Some(Blue),
          push_gauge_fg: Some(Reset),
          tag_fg: Some(LightMagenta),
          branch_fg: Some(LightYellow)
      )
    ''}

    # Test keyConfig content
    assertFileContent home-files/.config/gitui/key_bindings.ron ${pkgs.writeText "expected-keyconfig.ron" ''
      (
          focus_right: Some(( code: Char('l'), modifiers: ( bits: 0,),)),
          focus_left: Some(( code: Char('h'), modifiers: ( bits: 0,),)),
          focus_up: Some(( code: Char('k'), modifiers: ( bits: 0,),)),
          focus_down: Some(( code: Char('j'), modifiers: ( bits: 0,),)),
      )
    ''}
  '';
}
