{
  programs.rbenv = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  nmt.script = ''
    # Verify rbenv package is available
    assertNotNull "$(command -v rbenv)"
  '';
}
