{ config, ... }:

{
  config = {
    programs.lazygit = {
      enable = true;
    };

    nmt.script = ''
      # Test that lazygit is enabled but no config file is created with default settings
      assertPathNotExists home-files/.config/lazygit/config.yml
    '';
  };
}
