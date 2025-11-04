{
  config = {
    services.hound = {
      enable = true;
      maxConcurrentIndexers = 4;
      databasePath = "/tmp/hound-test";
      listenAddress = "0.0.0.0:8080";
      repositories = {
        TestRepo = {
          url = "https://github.com/example/repo.git";
          ms-between-poll = 5000;
          exclude-dot-files = true;
        };
        AnotherRepo = {
          url = "https://github.com/test/test.git";
          ms-between-poll = 15000;
        };
      };
    };

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/hound.service
      assertFileExists $serviceFile

      # Test custom listen address in service command
      assertFileRegex $serviceFile 'ExecStart=.*houndd --addr 0.0.0.0:8080 --conf .*hound-config.json'

      # Test configuration file generation with custom values
      configFile=$(grep -o '/[^[:space:]]*hound-config.json' $serviceFile | head -1)
      assertFileExists "$configFile"

      # Test custom configuration values
      assertFileRegex "$configFile" '"max-concurrent-indexers": 4'
      assertFileRegex "$configFile" '"dbpath": "/tmp/hound-test"'
      assertFileRegex "$configFile" '"health-check-url": "/healthz"'

      # Test repository configuration
      assertFileRegex "$configFile" '"TestRepo": {'
      assertFileRegex "$configFile" '"url": "https://github.com/example/repo.git"'
      assertFileRegex "$configFile" '"ms-between-poll": 5000'
      assertFileRegex "$configFile" '"exclude-dot-files": true'

      assertFileRegex "$configFile" '"AnotherRepo": {'
      assertFileRegex "$configFile" '"url": "https://github.com/test/test.git"'
      assertFileRegex "$configFile" '"ms-between-poll": 15000'
    '';
  };
}
