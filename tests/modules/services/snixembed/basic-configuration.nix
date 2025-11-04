{
  services.snixembed = {
    enable = true;
    beforeUnits = [ "safeeyes.service" ];
  };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/snixembed.service
    assertFileContent \
      home-files/.config/systemd/user/snixembed.service \
      ${./basic-configuration.service}
  '';
}
