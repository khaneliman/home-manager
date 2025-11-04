{ config, pkgs, ... }:

{
  config = {
    programs.vim = {
      enable = true;
      plugins = [
        pkgs.vimPlugins.vim-sensible
        pkgs.vimPlugins.vim-airline
        pkgs.vimPlugins.nerdtree
      ];
    };

    nmt.script = ''
      # Test that vim plugins are properly configured
      assertFileRegex home-path/bin/vim \
        'vim-sensible'

      assertFileRegex home-path/bin/vim \
        'vim-airline'

      assertFileRegex home-path/bin/vim \
        'nerdtree'
    '';
  };
}
