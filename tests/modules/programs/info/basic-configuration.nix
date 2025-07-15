{
  config = {
    programs.info.enable = true;

    nmt.script = ''
      assertFileExists home-files/.infokey
    '';
  };
}
