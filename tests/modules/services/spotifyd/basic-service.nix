{ ... }:

{
  services.spotifyd = {
    enable = true;
    settings = { };
  };

  test.stubs.spotifyd = { };

  nmt.script = ''
    assertFileContent \
      home-files/.config/systemd/user/spotifyd.service \
      ${./basic-service-expected.service}
  '';
}