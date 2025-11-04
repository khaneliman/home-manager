{ config, ... }:

{
  config = {
    services.etesync-dav = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/etesync-dav.service
      assertFileContent \
        home-files/.config/systemd/user/etesync-dav.service \
        ${./basic-configuration-expected.service}
    '';
  };
}
