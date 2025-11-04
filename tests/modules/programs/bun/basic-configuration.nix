{ config, ... }:

{
  config = {
    programs.bun = {
      enable = true;
    };

    nmt.script = ''
      # Test that bun is enabled but no config file is created with default settings
      assertPathNotExists home-files/.config/.bunfig.toml
    '';
  };
}
