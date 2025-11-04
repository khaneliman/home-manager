{
  config = {
    programs.opam.enable = true;

    nmt.script = ''
      # Test bash integration (enabled by default)
      assertFileExists home-files/.bashrc
      assertFileRegex home-files/.bashrc 'opam env --shell=bash'

      # Test zsh integration (enabled by default)
      assertFileExists home-files/.zshrc
      assertFileRegex home-files/.zshrc 'opam env --shell=zsh'

      # Test fish integration (enabled by default)
      assertFileExists home-files/.config/fish/config.fish
      assertFileRegex home-files/.config/fish/config.fish 'opam env --shell=fish'
    '';
  };
}
