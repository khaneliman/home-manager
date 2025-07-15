{
  config = {
    programs.opam = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
      enableFishIntegration = false;
    };

    nmt.script = ''
      # No shell integrations should be created when disabled
      assertPathNotExists home-files/.bashrc
      assertPathNotExists home-files/.zshrc
      assertPathNotExists home-files/.config/fish/config.fish
    '';
  };
}
