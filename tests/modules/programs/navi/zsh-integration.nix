{ config, ... }:

{
  config = {
    programs.navi = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.zshrc \
        'if.*options\[zle\].*on'

      assertFileRegex home-files/.zshrc \
        'eval.*navi widget zsh'
    '';
  };
}
