{ config, ... }:

{
  config = {
    services.batsignal = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/batsignal.service
      assertFileContent \
        home-files/.config/systemd/user/batsignal.service \
        ${./basic-service-expected.service}
    '';
  };
}
