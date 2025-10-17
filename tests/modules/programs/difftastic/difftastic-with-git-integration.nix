{
  programs.difftastic = {
    enable = true;
    enableGitIntegration = true;
    options = {
      color = "always";
      display = "side-by-side";
    };
  };

  programs.git.enable = true;

  nmt.script = ''
    assertFileExists home-files/.config/git/config
    assertFileContains home-files/.config/git/config '[diff]'
    assertFileRegex home-files/.config/git/config 'external = .*/difft.*--color.*--display'
  '';
}
