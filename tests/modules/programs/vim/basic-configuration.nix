{ config, ... }:

{
  config = {
    programs.vim = {
      enable = true;
    };

    nmt.script = ''
      # Test that vim is enabled with default vim-sensible plugin
      assertFileRegex home-path/bin/vim \
        '@vim-full@'
    '';
  };
}
