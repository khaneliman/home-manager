{ config, ... }:

{
  config = {
    programs.vim = {
      enable = true;
      defaultEditor = true;
    };

    nmt.script = ''
      # Test that vim is set as default editor
      assertFileRegex home-path/etc/profile.d/hm-session-vars.sh \
        'export EDITOR="vim"'
    '';
  };
}
