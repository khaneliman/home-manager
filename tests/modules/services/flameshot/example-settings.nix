{
  services.flameshot = {
    enable = true;

    settings = {
      General = {
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;
      };
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/flameshot/flameshot.ini
    assertFileContent \
      home-files/.config/flameshot/flameshot.ini \
      ${builtins.toFile "expected.ini" ''
        [General]
        disabledTrayIcon=true
        showStartupLaunchMessage=false
      ''}
  '';
}
