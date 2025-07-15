{ config, ... }:

{
  config = {
    programs.tealdeer = {
      enable = true;
    };

    nmt.script = ''
      # Test that tealdeer is enabled but no config file is created with default settings
      assertPathNotExists home-files/.config/tealdeer/config.toml

      # Test that auto-updates service is enabled by default
      assertFileExists home-files/.config/systemd/user/tldr-update.timer
    '';
  };
}
