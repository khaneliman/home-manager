{ config, ... }:

{
  config = {
    services.xembed-sni-proxy = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/xembed-sni-proxy.service \
        ${./basic-service-expected.service}
    '';
  };
}
