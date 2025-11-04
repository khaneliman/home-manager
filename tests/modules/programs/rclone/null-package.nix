{
  config = {
    programs.rclone = {
      enable = true;
      package = null;
    };

    nmt.script = ''
      # With null package, rclone should not be added to home.packages
      assertPathNotExists home-path/bin/rclone
    '';
  };
}
