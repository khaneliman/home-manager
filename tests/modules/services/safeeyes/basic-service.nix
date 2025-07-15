{ ... }:

{
  services.safeeyes = {
    enable = true;
  };

  test.stubs.safeeyes = { };

  nmt.script = ''
    assertFileContent \
      home-files/.config/systemd/user/safeeyes.service \
      ${./basic-service-expected.service}
  '';
}
