{ config, ... }:

{
  config = {
    programs.havoc = {
      enable = true;
    };

    nmt.script = ''
      # Should not create config file when settings are empty
      assertPathNotExists home-files/.config/havoc.cfg
    '';
  };
}
