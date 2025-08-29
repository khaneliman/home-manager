{
  programs.nyxt = {
    enable = true;
    config = ./example-config.lisp;
  };

  nmt.script = ''
    assertFileExists home-files/.config/nyxt/config.lisp
    assertFileContent home-files/.config/nyxt/config.lisp \
    ${./example-config.lisp}
  '';
}
