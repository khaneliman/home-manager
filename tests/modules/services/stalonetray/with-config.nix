{
  config = {
    services.stalonetray = {
      enable = true;
      config = {
        geometry = "3x1-600+0";
        decorations = null;
        icon_size = 30;
        sticky = true;
        background = "#cccccc";
      };
    };

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/stalonetray.service
      configFile=$TESTED/home-files/.config/stalonetrayrc

      assertFileExists $serviceFile
      assertFileExists $configFile

      # Test service configuration
      assertFileRegex $serviceFile 'ExecStart=.*stalonetray'

      # Test configuration file content
      assertFileRegex $configFile 'geometry "3x1-600+0"'
      assertFileRegex $configFile 'decorations none'
      assertFileRegex $configFile 'icon_size "30"'
      assertFileRegex $configFile 'sticky "true"'
      assertFileRegex $configFile 'background "#cccccc"'
    '';
  };
}
