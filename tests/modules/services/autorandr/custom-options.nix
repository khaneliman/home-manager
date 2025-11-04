{ config, ... }:

{
  config = {
    services.autorandr = {
      enable = true;
      ignoreLid = true;
      matchEdid = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/autorandr.service
      assertFileContent \
        home-files/.config/systemd/user/autorandr.service \
        ${./custom-options-expected.service}
    '';
  };
}
