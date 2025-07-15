{
  config = {
    services.dwm-status = {
      enable = true;
      order = [
        "time"
        "battery"
        "audio"
      ];
      extraConfig = {
        separator = " | ";
        battery = {
          notifier_levels = [
            5
            10
            15
            20
          ];
          icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };
        time = {
          format = "%a %b %d %I:%M %p";
        };
        audio = {
          mute_indicator = "󰝟";
        };
      };
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/dwm-status.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=DWM status service'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'
      assertFileRegex $serviceFile 'WantedBy=graphical-session.target'

      # Test command line with config file
      assertFileRegex $serviceFile 'ExecStart=.*dwm-status.*/nix/store/.*dwm-status.json.*--quiet'

      # Extract and test JSON config file
      jsonConfigPath=$(grep -o '/nix/store/[^[:space:]]*.json' $serviceFile)
      assertFileExists "$jsonConfigPath"

      # Test JSON config structure and values
      assertFileRegex "$jsonConfigPath" '"order":\["time","battery","audio"\]'
      assertFileRegex "$jsonConfigPath" '"separator":" | "'
      assertFileRegex "$jsonConfigPath" '"notifier_levels":\[5,10,15,20\]'
      assertFileRegex "$jsonConfigPath" '"format":"%a %b %d %I:%M %p"'
      assertFileRegex "$jsonConfigPath" '"mute_indicator":"󰝟"'
    '';
  };
}
