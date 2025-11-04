{
  config = {
    services.wluma = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/wluma.service
      assertFileContent \
        home-files/.config/systemd/user/wluma.service \
        ${./basic-service-expected.service}
    '';
  };
}
