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
      remotes = {
        gdrive = {
          config = {
            type = "drive";
            client_id = "example_id";
            scope = "drive";
          };
          mounts = {
            "Documents" = {
              enable = true;
              mountPoint = "/home/user/gdrive-docs";
              options = {
                dir-cache-time = "5000h";
                poll-interval = "10s";
                umask = "002";
              };
            };
          };
        };
      };
    };

    nmt.script = ''
      # Check that systemd service is created for the mount
      serviceFile="home-files/.config/systemd/user/rclone-mount:Documents@gdrive.service"
      assertFileExists "$serviceFile"

      # Check service configuration
      assertFileRegex "$serviceFile" 'Description=Rclone FUSE daemon for gdrive:Documents'
      assertFileRegex "$serviceFile" 'ExecStartPre=.*mkdir -p /home/user/gdrive-docs'
      assertFileRegex "$serviceFile" 'ExecStart=.*rclone mount'
      assertFileRegex "$serviceFile" 'ExecStart=.*--dir-cache-time 5000h'
      assertFileRegex "$serviceFile" 'ExecStart=.*--poll-interval 10s'
      assertFileRegex "$serviceFile" 'ExecStart=.*--umask 002'
      assertFileRegex "$serviceFile" 'ExecStart=.*gdrive:Documents'
      assertFileRegex "$serviceFile" 'ExecStart=.*/home/user/gdrive-docs'
      assertFileRegex "$serviceFile" 'Restart=on-failure'
      assertFileRegex "$serviceFile" 'WantedBy=default.target'
    '';
  };
}
