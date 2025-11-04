{ config, ... }:

{
  config = {
    services.batsignal = {
      enable = true;
      extraArgs = [
        "-w"
        "30"
        "-c"
        "15"
        "-d"
        "5"
      ];
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/batsignal.service
      assertFileContent \
        home-files/.config/systemd/user/batsignal.service \
        ${./custom-args-expected.service}
    '';
  };
}
