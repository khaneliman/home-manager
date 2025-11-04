{
  services.ssh-agent = {
    enable = true;
    defaultMaximumIdentityLifetime = 1337;
  };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/ssh-agent.service
    assertFileContent \
      home-files/.config/systemd/user/ssh-agent.service \
      ${./timeout-service-expected.service}
  '';
}
