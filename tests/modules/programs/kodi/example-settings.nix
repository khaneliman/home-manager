{
  imports = [ ./kodi-stubs.nix ];

  programs.kodi = {
    enable = true;
    settings = {
      videolibrary.showemptytvshows = "true";
    };
  };

  nmt.script = ''
    assertFileExists home-files/.kodi/userdata/advancedsettings.xml
    assertFileContent \
      home-files/.kodi/userdata/advancedsettings.xml \
      ${./example-settings-expected.xml}
  '';
}
