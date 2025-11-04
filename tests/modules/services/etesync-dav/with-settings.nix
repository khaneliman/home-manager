{ config, ... }:

{
  config = {
    services.etesync-dav = {
      enable = true;
      serverUrl = "https://api.etebase.com/partner/etesync/";
      settings = {
        ETESYNC_LISTEN_ADDRESS = "localhost";
        ETESYNC_LISTEN_PORT = 37358;
        ETESYNC_DEBUG = "true";
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/etesync-dav.service
      assertFileContent \
        home-files/.config/systemd/user/etesync-dav.service \
        ${./with-settings-expected.service}
    '';
  };
}
