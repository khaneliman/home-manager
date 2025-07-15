{
  programs.piston-cli = {
    enable = true;
  };

  nmt.script = ''
    # Verify piston-cli package is available
    assertNotNull "$(command -v piston)"
  '';
}
