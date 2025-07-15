{
  programs.skim = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  nmt.script = ''
    # Verify skim package is available
    assertNotNull "$(command -v sk)"
  '';
}
