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
      assertFileContent \
        home-files/.config/systemd/user/autorandr.service \
        ${./extra-options-expected.service}
    '';
  };
}
