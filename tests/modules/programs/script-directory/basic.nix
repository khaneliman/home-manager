{
  programs.script-directory = {
    enable = true;
  };

  nmt.script = ''
    # Verify sd package is available
    assertNotNull "$(command -v sd)"
  '';
}
