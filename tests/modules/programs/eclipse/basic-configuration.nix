{
  config = {
    programs.eclipse.enable = true;

    nmt.script = ''
      assertFileExists home-files/.eclipse/configuration/config.ini
    '';
  };
}
