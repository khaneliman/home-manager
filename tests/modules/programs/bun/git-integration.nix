{ config, ... }:

{
  config = {
    programs.bun = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.git.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.config/git/config \
        '\[diff "lockb"\]'

      assertFileRegex home-files/.config/git/config \
        'textconv = @bun@'

      assertFileRegex home-files/.config/git/config \
        'binary = true'

      assertFileExists home-files/.config/git/attributes
      assertFileRegex home-files/.config/git/attributes \
        '\*\.lockb binary diff=lockb'
    '';
  };
}
