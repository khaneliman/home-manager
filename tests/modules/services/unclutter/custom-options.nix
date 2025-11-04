{ config, ... }:

{
  config = {
    services.unclutter = {
      enable = true;
      timeout = 5;
      threshold = 10;
      extraOptions = [
        "exclude-root"
        "ignore-scrolling"
      ];
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/unclutter.service
      assertFileContent \
        home-files/.config/systemd/user/unclutter.service \
        ${./custom-options-expected.service}
    '';
  };
}
