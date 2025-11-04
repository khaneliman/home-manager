{
  config = {
    programs.ion.enable = true;

    nmt.script = ''
      assertFileExists home-files/.config/ion/initrc
    '';
  };
}
