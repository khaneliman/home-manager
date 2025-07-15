{
  config = {
    programs.hstr.enable = true;

    nmt.script = ''
      assertFileExists home-files/.hstr_favorites
    '';
  };
}
