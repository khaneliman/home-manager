{
  programs.foot = {
    enable = true;
    server.enable = true;
  };

  nmt.script = ''
    assertPathNotExists home-files/.config/foot/foot.ini

    assertFileExists home-files/.config/systemd/user/foot.service
    assertFileContent \
      home-files/.config/systemd/user/foot.service \
      ${./systemd-user-service-expected.service}
  '';
}
