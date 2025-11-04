{ ... }:

{
  services.lorri.enable = true;

  test.stubs.lorri = { };

  nmt.script = ''
    serviceFile=$(normalizeStorePaths home-files/.config/systemd/user/lorri.service)
    assertFileContent "$serviceFile" ${./basic-service-expected.service}

    socketFile=$(normalizeStorePaths home-files/.config/systemd/user/lorri.socket)
    assertFileContent "$socketFile" ${./basic-socket-expected.socket}
  '';
}
