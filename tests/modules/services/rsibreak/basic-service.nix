{ ... }:

{
  services.rsibreak = {
    enable = true;
  };

  test.stubs.rsibreak = { };

  nmt.script = ''
    assertFileContent \
      home-files/.config/systemd/user/rsibreak.service \
      ${./basic-service-expected.service}
  '';
}