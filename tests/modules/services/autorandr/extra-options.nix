{ config, ... }:

{
  config = {
    services.autorandr = {
      enable = true;
      extraOptions = [
        "--force"
        "--verbose"
      ];
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/autorandr.service
      assertFileContent \
        home-files/.config/systemd/user/autorandr.service \
        ${./extra-options-expected.service}
    '';
  };
}
