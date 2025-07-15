{
  config = {
    services.wluma = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/wluma.service \
        ${./basic-service-expected.service}
    '';
  };
}
