{
  config = {
    programs.notmuch.enable = true;
    services.muchsync.remotes.test = {
      remote.host = "test.example.com";
    };

    nmt.script = ''
      serviceFile=$TESTED/home-files/.config/systemd/user/muchsync-test.service
      timerFile=$TESTED/home-files/.config/systemd/user/muchsync-test.timer

      assertFileExists $serviceFile
      assertFileExists $timerFile

      # Test service configuration
      assertFileRegex $serviceFile 'Description=muchsync sync service (test)'
      assertFileRegex $serviceFile 'CPUSchedulingPolicy=idle'
      assertFileRegex $serviceFile 'IOSchedulingClass=idle'

      # Test executable and remote host
      assertFileRegex $serviceFile 'ExecStart=.*muchsync'
      assertFileRegex $serviceFile 'test.example.com'

      # Test timer configuration
      assertFileRegex $timerFile 'Description=muchsync periodic sync (test)'
      assertFileRegex $timerFile 'Unit=muchsync-test.service'
      assertFileRegex $timerFile 'OnCalendar=\*:0/5'
      assertFileRegex $timerFile 'WantedBy=timers.target'
    '';
  };
}
