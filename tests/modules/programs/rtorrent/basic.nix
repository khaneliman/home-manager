{
  programs.rtorrent = {
    enable = true;
  };

  nmt.script = ''
    # Verify rtorrent package is available
    assertNotNull "$(command -v rtorrent)"
  '';
}
