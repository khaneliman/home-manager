{
  programs = {
    zsh.enable = true;

    oh-my-posh = {
      enable = true;
      useTheme = "jandedobbeleer";
    };
  };

  nmt.script = ''
    assertFileExists home-files/.zshrc
    assertFileContains \
      home-files/.zshrc \
      'export OMP_CACHE_DIR=/home/hm-user/.cache/oh-my-posh-generations/'
    assertFileContains \
      home-files/.zshrc \
      '/bin/oh-my-posh init zsh --config'
  '';
}
