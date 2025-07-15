{
  config = {
    programs.bashmount.enable = true;

    nmt.script = ''
      assertFileExists home-files/.config/bashmount/config
    '';
  };
}
