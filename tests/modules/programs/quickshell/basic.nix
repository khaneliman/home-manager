{
  programs.quickshell = {
    enable = true;
  };

  nmt.script = ''
    # Verify quickshell package is available
    assertNotNull "$(command -v quickshell)"
  '';
}
