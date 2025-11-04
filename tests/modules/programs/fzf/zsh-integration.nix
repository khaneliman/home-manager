{ config, ... }:

{
  config = {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.zshrc \
        'source <(@fzf@/bin/fzf --zsh)'
    '';
  };
}
