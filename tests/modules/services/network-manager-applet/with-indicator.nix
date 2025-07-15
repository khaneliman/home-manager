{ config, ... }:

{
  config = {
    services.network-manager-applet = {
      enable = true;
    };

    xsession.preferStatusNotifierItems = true;

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/network-manager-applet.service \
        ${./with-indicator-expected.service}
    '';
  };
}
