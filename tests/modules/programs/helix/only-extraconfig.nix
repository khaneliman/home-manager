{
  programs.helix = {
    enable = true;
    extraConfig = ''
      [editor]
      auto-pairs = false
    '';
  };

  nmt.script = ''
    assertFileExists home-files/.config/helix/config.toml
    assertFileContent \
      home-files/.config/helix/config.toml \
      ${./only-extraconfig-expected.toml}
  '';
}
