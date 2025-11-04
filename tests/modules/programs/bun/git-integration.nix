{
  config = {
    programs.bun = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.git.enable = true;

    nmt.script = ''
      assertFileExists home-files/.config/git/config
      assertFileRegex home-files/.config/git/config \
        '\[diff "lockb"\]'
      assertFileContains home-files/.config/git/config \
        'binary = true'
      assertFileContains home-files/.config/git/config \
        'textconv = "@bun@/bin/bun"'

      assertFileExists home-files/.config/git/attributes
      assertFileRegex home-files/.config/git/attributes \
        '\*\.lockb binary diff=lockb'
    '';
  };
}
