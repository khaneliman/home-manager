{
  programs.git-lfs = {
    enable = true;
    skipSmudge = true;
  };
  programs.git.enable = true;

  nmt.script = ''
    # Git config should NOT contain git-lfs configuration since enableGitIntegration is false by default
    assertFileNotRegex home-files/.config/git/config '\[filter "lfs"\]'
  '';
}
