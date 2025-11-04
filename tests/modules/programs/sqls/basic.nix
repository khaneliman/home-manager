{
  programs.sqls = {
    enable = true;
  };

  nmt.script = ''
    # Verify sqls package is available
    assertNotNull "$(command -v sqls)"
  '';
}
