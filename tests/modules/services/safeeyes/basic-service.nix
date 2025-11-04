{ ... }:

{
  services.safeeyes = {
    enable = true;
  };

  test.stubs.safeeyes = { };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/safeeyes.service
    assertFileContent \
      home-files/.config/systemd/user/safeeyes.service \
      ${./basic-service-expected.service}
  '';
}
