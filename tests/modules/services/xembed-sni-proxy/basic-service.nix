{ config, ... }:

{
  config = {
    services.xembed-sni-proxy = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/xembed-sni-proxy.service
      assertFileContent \
        home-files/.config/systemd/user/xembed-sni-proxy.service \
        ${./basic-service-expected.service}
    '';
  };
}
