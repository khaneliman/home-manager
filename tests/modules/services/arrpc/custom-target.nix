{
  config,
  lib,
  ...
}:

{
  config = {
    services.arrpc = {
      enable = true;
      package = config.lib.test.mkStubPackage { outPath = "@arrpc@"; };
      systemdTarget = "sway-session.target";
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/arRPC.service \
        ${./custom-target-expected.service}
    '';
  };
}
