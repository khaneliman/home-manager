{
  config = {
    services.dwm-status = {
      enable = true;
      order = [
        "time"
        "battery"
        "network"
      ];
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/dwm-status.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=DWM status service'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'

      # Test command includes config file and quiet flag
      assertFileRegex $serviceFile 'ExecStart=.*dwm-status.*/nix/store/.*dwm-status.json.*--quiet'

      # Test that JSON config file exists and has correct structure
      jsonConfigPath=$(grep -o '/nix/store/[^[:space:]]*.json' $serviceFile)
      assertFileExists "$jsonConfigPath"

      # Test JSON config contains the order
      assertFileRegex "$jsonConfigPath" '"order":\["time","battery","network"\]'
    '';
  };
}
