{
  config = {
    programs.keychain = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;
      enableNushellIntegration = false;
      enableXsessionIntegration = false;
    };

    nmt.script = ''
      # All integrations disabled - no shell files should be modified
      assertPathNotExists home-files/.bashrc
      assertPathNotExists home-files/.zshrc
      assertPathNotExists home-files/.config/fish/config.fish
      assertPathNotExists home-files/.config/nushell/config.nu
      assertPathNotExists home-files/.xsession
    '';
  };
}
