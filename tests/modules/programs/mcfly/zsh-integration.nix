{ config, ... }:

{
  config = {
    programs.mcfly = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.zshrc \
        'eval.*mcfly.*init zsh'
    '';
  };
}
