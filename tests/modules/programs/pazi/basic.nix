{
  programs.pazi = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  nmt.script = ''
    # Verify package is available
    assertNotNull "$(command -v pazi)"
  '';
}
