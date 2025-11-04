{
  config = {
    programs.floorp.enable = true;

    nmt.script = ''
      assertFileExists home-files/.floorp/profiles.ini
    '';
  };
}
