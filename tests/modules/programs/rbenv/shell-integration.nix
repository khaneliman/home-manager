{
  programs = {
    bash.enable = true;
    zsh.enable = true;
    fish.enable = true;

    rbenv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };

  nmt.script = ''
    # Check bash integration
    if [[ -f home-files/.bashrc ]]; then
      assertFileRegex home-files/.bashrc 'rbenv init.*bash'
    fi

    # Check zsh integration
    if [[ -f home-files/.zshrc ]]; then
      assertFileRegex home-files/.zshrc 'rbenv init.*zsh'
    fi

    # Check fish integration
    if [[ -f home-files/.config/fish/config.fish ]]; then
      assertFileRegex home-files/.config/fish/config.fish 'rbenv init.*fish'
    fi
  '';
}
