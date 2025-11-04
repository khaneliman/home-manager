{
  config = {
    programs.opam = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    nmt.script = ''
      # Test bash integration
      assertFileExists home-files/.bashrc
      assertFileRegex home-files/.bashrc 'opam env --shell=bash'

      # Test zsh integration  
      assertFileExists home-files/.zshrc
      assertFileRegex home-files/.zshrc 'opam env --shell=zsh'

      # Test fish integration
      assertFileExists home-files/.config/fish/config.fish
      assertFileRegex home-files/.config/fish/config.fish 'opam env --shell=fish'
    '';
  };
}
