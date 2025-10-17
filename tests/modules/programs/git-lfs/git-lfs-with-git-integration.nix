{
  programs.git-lfs = {
    enable = true;
    enableGitIntegration = true;
    skipSmudge = true;
  };

  programs.git.enable = true;

  nmt.script = ''
    assertFileExists home-files/.config/git/config
    assertFileContains home-files/.config/git/config '[filter "lfs"]'
    assertFileContains home-files/.config/git/config 'clean = "git-lfs clean -- %f"'
    assertFileRegex home-files/.config/git/config 'process = "git-lfs filter-process --skip"'
    assertFileContains home-files/.config/git/config 'required = true'
    assertFileRegex home-files/.config/git/config 'smudge = "git-lfs smudge --skip -- %f"'
  '';
}
