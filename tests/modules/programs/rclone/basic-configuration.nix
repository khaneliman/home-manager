{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.rclone = {
      enable = true;
      remotes = { };
    };

    nmt.script = ''
      # Test that no config file is created when no remotes are configured
      assertPathNotExists home-files/.config/rclone

      # Test that no systemd services are created
      assertPathNotExists home-files/.config/systemd/user/rclone-mount*
    '';
  };
}
