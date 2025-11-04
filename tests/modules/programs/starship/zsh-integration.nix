{ config, ... }:

{
  config = {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.zshrc \
        'if.*TERM.*dumb'

      assertFileRegex home-files/.zshrc \
        'eval.*starship.*init zsh'
    '';
  };
}
