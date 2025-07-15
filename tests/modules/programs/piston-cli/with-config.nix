{
  programs.piston-cli = {
    enable = true;
    settings = {
      theme = "emacs";
      box_style = "MINIMAL_DOUBLE_HEAD";
      prompt_continuation = "...";
      prompt_start = ">>>";
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/piston-cli/config.yml
    assertFileContent home-files/.config/piston-cli/config.yml ${builtins.toFile "piston-cli-config.yml" ''
      box_style: MINIMAL_DOUBLE_HEAD
      prompt_continuation: '...'
      prompt_start: '>>>'
      theme: emacs
    ''}
  '';
}
