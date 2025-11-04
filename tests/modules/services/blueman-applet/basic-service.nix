{ config, ... }:

{
  config = {
    services.blueman-applet = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/blueman-applet.service
      assertFileContent \
        home-files/.config/systemd/user/blueman-applet.service \
        ${./basic-service-expected.service}
    '';
  };
}
