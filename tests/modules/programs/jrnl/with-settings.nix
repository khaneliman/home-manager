{
  config = {
    programs.jrnl = {
      enable = true;
      settings = {
        default_journal = "~/journal.txt";
        editor = "vim";
        encrypt = false;
        highlight = true;
        linewrap = 80;
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/jrnl/jrnl.yaml
      assertFileRegex home-files/.config/jrnl/jrnl.yaml 'default_journal.*journal\.txt'
      assertFileRegex home-files/.config/jrnl/jrnl.yaml 'editor.*vim'
      assertFileRegex home-files/.config/jrnl/jrnl.yaml 'encrypt.*false'
      assertFileRegex home-files/.config/jrnl/jrnl.yaml 'highlight.*true'
      assertFileRegex home-files/.config/jrnl/jrnl.yaml 'linewrap.*80'
    '';
  };
}
