{
  programs.pidgin = {
    enable = true;
  };

  nmt.script = ''
    # Verify pidgin package is available
    assertNotNull "$(command -v pidgin)"
  '';
}
