{
  services.ssh-agent = {
    enable = true;
    socket = "ssh-agent/socket";
  };

  nmt.script = ''
    assertFileExists home-files/.config/systemd/user/ssh-agent.service
    assertFileContent \
      home-files/.config/systemd/user/ssh-agent.service \
      ${./basic-service-expected.service}
  '';
}
