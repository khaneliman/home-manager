{
  programs = {
    bash.enable = true;
    zsh.enable = true;
    fish.enable = true;

    skim = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };

  nmt.script = ''
    # Check bash integration
    if [[ -f home-files/.bashrc ]]; then
      assertFileRegex home-files/.bashrc 'skim/completion.bash'
      assertFileRegex home-files/.bashrc 'skim/key-bindings.bash'
    fi

    # Check zsh integration
    if [[ -f home-files/.zshrc ]]; then
      assertFileRegex home-files/.zshrc 'skim/completion.zsh'
      assertFileRegex home-files/.zshrc 'skim/key-bindings.zsh'
    fi

    # Check fish integration
    if [[ -f home-files/.config/fish/config.fish ]]; then
      assertFileRegex home-files/.config/fish/config.fish 'skim/key-bindings.fish'
    fi
  '';
}
