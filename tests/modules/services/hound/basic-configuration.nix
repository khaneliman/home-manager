{
  config = {
    services.hound.enable = true;

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/hound.service
      assertFileExists $serviceFile

      # Test systemd service configuration
      assertFileRegex $serviceFile 'Description=Hound source code search engine'
      assertFileRegex $serviceFile 'WantedBy=default.target'

      # Test executable and configuration file
      assertFileRegex $serviceFile 'ExecStart=.*houndd --addr localhost:6080 --conf .*hound-config.json'

      # Test PATH environment includes git and mercurial
      assertFileRegex $serviceFile 'Environment=PATH=.*git.*'
      assertFileRegex $serviceFile 'Environment=PATH=.*mercurial.*'

      # Test configuration file generation
      configFile=$(grep -o '/[^[:space:]]*hound-config.json' $serviceFile | head -1)
      assertFileExists "$configFile"

      # Test default JSON configuration values
      assertFileRegex "$configFile" '"max-concurrent-indexers": 2'
      assertFileRegex "$configFile" '"dbpath": ".*/.local/share/hound"'
      assertFileRegex "$configFile" '"health-check-url": "/healthz"'
      assertFileRegex "$configFile" '"repos": {}'
    '';
  };
}
