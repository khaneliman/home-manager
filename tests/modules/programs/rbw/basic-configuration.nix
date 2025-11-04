{ config, ... }:

{
  config = {
    programs.rbw = {
      enable = true;
    };

    nmt.script = ''
      # Test that rbw is enabled but no config file is created with default settings
      assertPathNotExists home-files/.config/rbw/config.json
    '';
  };
}
