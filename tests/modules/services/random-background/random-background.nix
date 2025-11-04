{ ... }:

{
  services.random-background = {
    enable = true;
    imageDirectory = "/usr/share/backgrounds";
    display = "scale";
    enableXinerama = false;
    interval = "30m";
  };

  test.stubs.feh = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/random-background.service
    assertFileContent \
      home-files/.config/systemd/user/random-background.service \
      ${./random-background-expected.service}

    assertFileExists home-files/.config/systemd/user/random-background.timer
    assertFileContent \
      home-files/.config/systemd/user/random-background.timer \
      ${./random-background-expected.timer}
  '';
}
