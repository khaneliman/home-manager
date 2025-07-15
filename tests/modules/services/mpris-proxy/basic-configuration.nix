{
  config = {
    services.mpris-proxy.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/mpris-proxy.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Proxy forwarding Bluetooth MIDI controls via MPRIS2 to control media players'
      assertFileRegex $serviceFile 'WantedBy=bluetooth.target'
      assertFileRegex $serviceFile 'BindsTo=bluetooth.target'
      assertFileRegex $serviceFile 'After=bluetooth.target'

      # Test service type and executable
      assertFileRegex $serviceFile 'Type=simple'
      assertFileRegex $serviceFile 'ExecStart=.*mpris-proxy'
    '';
  };
}
