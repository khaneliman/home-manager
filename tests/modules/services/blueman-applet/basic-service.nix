{ config, ... }:

{
  config = {
    services.blueman-applet = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/blueman-applet.service \
        ${./basic-service-expected.service}
    '';
  };
}
