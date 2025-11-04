{ ... }:

{
  services.spotifyd = {
    enable = true;
    settings = { };
  };

  test.stubs.spotifyd = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/spotifyd.service
    assertFileContent \
      home-files/.config/systemd/user/spotifyd.service \
      ${./basic-service-expected.service}
  '';
}
