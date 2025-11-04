{
  services.signaturepdf = {
    enable = true;
    port = 9494;
    extraConfig = {
      upload_max_filesize = "24M";
    };
  };

  test.stubs.signaturepdf = {
    outPath = "/signaturepdf";
  };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/signaturepdf.service
    assertFileContent \
      home-files/.config/systemd/user/signaturepdf.service \
      ${./basic-configuration.service}

    assertFileExists home-path/share/applications/signaturepdf.desktop
    assertFileContent \
      home-path/share/applications/signaturepdf.desktop \
      ${./basic-configuration.desktop}
  '';
}
