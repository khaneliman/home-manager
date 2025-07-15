{
  config = {
    programs.keychain = {
      enable = true;
      keys = [
        "id_rsa"
        "id_ed25519"
      ];
      extraFlags = [
        "--quiet"
        "--timeout"
        "3600"
      ];
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableXsessionIntegration = false;
    };

    nmt.script = ''
      # Test bash integration
      assertFileExists home-files/.bashrc
      assertFileRegex home-files/.bashrc 'keychain.*--eval.*--quiet.*--timeout.*3600.*id_rsa.*id_ed25519'

      # Test zsh integration
      assertFileExists home-files/.zshrc
      assertFileRegex home-files/.zshrc 'keychain.*--eval.*--quiet.*--timeout.*3600.*id_rsa.*id_ed25519'

      # Test fish integration
      assertFileExists home-files/.config/fish/config.fish
      assertFileRegex home-files/.config/fish/config.fish 'keychain.*--eval.*--quiet.*--timeout.*3600.*id_rsa.*id_ed25519'

      # Test nushell integration
      assertFileExists home-files/.config/nushell/config.nu
      assertFileRegex home-files/.config/nushell/config.nu 'keychain.*--eval.*--quiet.*--timeout.*3600.*id_rsa.*id_ed25519'

      # Test that xsession integration is disabled
      assertPathNotExists home-files/.xsession
    '';
  };
}
