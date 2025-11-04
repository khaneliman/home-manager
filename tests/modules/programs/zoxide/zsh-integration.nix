{ config, ... }:

{
  config = {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.zshrc \
        'eval.*zoxide.*init zsh'
    '';
  };
}
