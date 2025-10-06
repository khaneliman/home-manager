{ config, ... }:

{
  config = {
    services.network-manager-applet = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/network-manager-applet.service \
        ${./basic-service-expected.service}
    '';
  };
}
