{
  programs = {
    bash.enable = true;

    oh-my-posh = {
      enable = true;
      useTheme = "jandedobbeleer";
    };
  };

  nmt.script = ''
    assertFileExists home-files/.bashrc
    assertFileContains \
      home-files/.bashrc \
      'export OMP_CACHE_DIR=/home/hm-user/.cache/oh-my-posh-generations/'
    assertFileContains \
      home-files/.bashrc \
      '/bin/oh-my-posh init bash --config'
    assertFileNotRegex activate 'ohMyPoshCreateCacheRoot'
    assertFileNotRegex activate 'pkg-path'
    assertFileNotRegex activate 'rm -rf .*/oh-my-posh'
  '';
}
