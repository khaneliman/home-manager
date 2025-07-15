{
  config = {
    programs.grep.enable = true;

    nmt.script = ''
      assertFileExists home-files/.greprc
    '';
  };
}
