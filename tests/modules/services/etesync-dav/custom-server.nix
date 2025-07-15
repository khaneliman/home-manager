{ config, ... }:

{
  config = {
    services.etesync-dav = {
      enable = true;
      serverUrl = "https://my-etesync.example.com/";
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/etesync-dav.service
      assertFileContent \
        home-files/.config/systemd/user/etesync-dav.service \
        ${./custom-server-expected.service}
    '';
  };
}
