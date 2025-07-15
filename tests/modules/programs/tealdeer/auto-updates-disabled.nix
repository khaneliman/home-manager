{ config, ... }:

{
  config = {
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = false;
    };

    nmt.script = ''
      # Test that auto-updates service is not enabled when disabled
      assertPathNotExists home-files/.config/systemd/user/tldr-update.timer
      assertPathNotExists home-files/.config/systemd/user/tldr-update.service
    '';
  };
}
