{ config, ... }:

{
  config = {
    programs.vim = {
      enable = true;
      settings = {
        expandtab = true;
        history = 1000;
        background = "dark";
        number = true;
        relativenumber = true;
        tabstop = 4;
        shiftwidth = 4;
      };
      extraConfig = ''
        set nocompatible
        set nobackup
      '';
    };

    nmt.script = ''
      # Test that vim settings are properly applied
      assertFileRegex home-path/bin/vim \
        'set expandtab'

      assertFileRegex home-path/bin/vim \
        'set history=1000'

      assertFileRegex home-path/bin/vim \
        'set background=dark'

      assertFileRegex home-path/bin/vim \
        'set number'

      assertFileRegex home-path/bin/vim \
        'set relativenumber'

      assertFileRegex home-path/bin/vim \
        'set tabstop=4'

      assertFileRegex home-path/bin/vim \
        'set shiftwidth=4'

      assertFileRegex home-path/bin/vim \
        'set nocompatible'

      assertFileRegex home-path/bin/vim \
        'set nobackup'
    '';
  };
}
