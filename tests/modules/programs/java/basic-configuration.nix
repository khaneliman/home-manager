{
  config = {
    programs.java.enable = true;

    nmt.script = ''
      assertFileExists home-files/.java/.userPrefs/.system.lock
    '';
  };
}
