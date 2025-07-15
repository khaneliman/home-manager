{ config, ... }:

{
  config = {
    services.batsignal = {
      enable = true;
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/batsignal.service \
        ${./basic-service-expected.service}
    '';
  };
}
