{
  config = {
    programs.hstr = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    programs.bash.enable = true;
    programs.zsh.enable = true;

    nmt.script = ''
      # Check that hstr integration is added to shell config
      assertFileRegex home-files/.bashrc \
        'eval.*hstr.*--show-configuration'
      assertFileRegex home-files/.zshrc \
        'eval.*hstr.*--show-zsh-configuration'
    '';
  };
}
