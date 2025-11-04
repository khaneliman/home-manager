{ ... }:

{
  services.pueue = {
    enable = true;
    settings = { };
  };

  test.stubs.pueue = { };

  nmt.script = ''
    assertFileExists home-files/.config/pueue/pueue.yml
    serviceFile=$(normalizeStorePaths home-files/.config/systemd/user/pueued.service)
    assertFileContent "$serviceFile" ${./basic-service-expected.service}
  '';
}
