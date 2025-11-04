{ ... }:

{
  services.rsibreak = {
    enable = true;
  };

  test.stubs.rsibreak = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/rsibreak.service
    assertFileContent \
      home-files/.config/systemd/user/rsibreak.service \
      ${./basic-service-expected.service}
  '';
}
