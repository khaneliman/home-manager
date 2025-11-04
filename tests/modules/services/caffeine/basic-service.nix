{ config, ... }:

{
  config = {
    services.caffeine = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/caffeine.service
      assertFileContent \
        home-files/.config/systemd/user/caffeine.service \
        ${./basic-service-expected.service}
    '';
  };
}
