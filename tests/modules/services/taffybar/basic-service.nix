{ config, ... }:

{
  config = {
    services.taffybar = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/taffybar.service
      assertFileContent \
        home-files/.config/systemd/user/taffybar.service \
        ${./basic-service-expected.service}

      # Check that GDK_PIXBUF_MODULE_FILE is imported in xsession
      assertFileRegex \
        home-files/.xsessionrc \
        'GDK_PIXBUF_MODULE_FILE'
    '';
  };
}
