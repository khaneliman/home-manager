{
  programs.cmus = {
    enable = true;
    theme = "gruvbox";
    extraConfig = "test";
  };

  nmt.script = ''
    assertFileExists home-files/.config/cmus/rc
    assertFileContent \
      home-files/.config/cmus/rc \
      ${builtins.toFile "cmus-expected-rc" ''
        colorscheme gruvbox
        test
      ''}
  '';
}
