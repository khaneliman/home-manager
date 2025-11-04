{ ... }:

{
  programs.gitui = {
    enable = true;
    keyConfig = ''
      exit: Some(( code: Char('c'), modifiers: ( bits: 2,),)),
      quit: Some(( code: Char('q'), modifiers: ( bits: 0,),)),
      exit_popup: Some(( code: Esc, modifiers: ( bits: 0,),)),
    '';
    theme = ''
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
  };

  test.stubs.gitui = { };

  nmt.script = ''
    assertFileExists home-files/.config/gitui/theme.ron
    assertFileContent \
      home-files/.config/gitui/theme.ron \
      ${./theme-expected.ron}

    assertFileExists home-files/.config/gitui/key_bindings.ron
    assertFileContent \
      home-files/.config/gitui/key_bindings.ron \
      ${./key-bindings-expected.ron}
  '';
}
