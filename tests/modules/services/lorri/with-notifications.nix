{ ... }:

{
  services.lorri = {
    enable = true;
    enableNotifications = true;
  };

  test.stubs = {
    lorri = { };
    jq = { };
    libnotify = { };
  };

  nmt.script = ''
    serviceFile=$(normalizeStorePaths home-files/.config/systemd/user/lorri.service)
    assertFileContent "$serviceFile" ${./basic-service-expected.service}

    socketFile=$(normalizeStorePaths home-files/.config/systemd/user/lorri.socket)
    assertFileContent "$socketFile" ${./basic-socket-expected.socket}

    notifyServiceFile=$(normalizeStorePaths home-files/.config/systemd/user/lorri-notify.service)
    assertFileContent "$notifyServiceFile" ${./notify-service-expected.service}
  '';
}
