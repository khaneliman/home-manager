{
  services.linux-wallpaperengine = {
    enable = true;
  };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/linux-wallpaperengine.service
    assertFileContent \
        home-files/.config/systemd/user/linux-wallpaperengine.service \
        ${./null-options-expected.service}
  '';
}
