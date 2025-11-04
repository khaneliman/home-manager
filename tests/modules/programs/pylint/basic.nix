{
  programs.pylint = {
    enable = true;
  };

  nmt.script = ''
    # Verify pylint package is available
    assertNotNull "$(command -v pylint)"
  '';
}
