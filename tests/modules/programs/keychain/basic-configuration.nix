{
  config = {
    programs = {
      bash.enable = true;
      fish.enable = true;
      nushell.enable = true;
      keychain.enable = true;
      zsh.enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.bashrc
      assertFileRegex home-files/.bashrc 'keychain.*--eval.*--quiet.*id_rsa'
      assertFileExists home-files/.config/fish/config.fish
      assertFileRegex home-files/.config/fish/config.fish 'keychain.*--eval.*--quiet.*id_rsa'
      assertFileExists home-files/.config/nushell/config.nu
      assertFileRegex home-files/.config/nushell/config.nu 'keychain.*--eval.*--quiet.*id_rsa'
      assertFileExists home-files/.zshrc
      assertFileRegex home-files/.zshrc 'keychain.*--eval.*--quiet.*id_rsa'
    '';
  };
}
