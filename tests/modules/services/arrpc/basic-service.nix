{
  config,
  ...
}:

{
  config = {
    services.arrpc = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/arRPC.service \
        ${./basic-service-expected.service}
    '';
  };
}
