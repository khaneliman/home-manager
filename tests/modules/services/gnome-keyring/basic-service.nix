{ config, ... }:

{
  config = {
    services.gnome-keyring = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/gnome-keyring.service
      assertFileContent \
        home-files/.config/systemd/user/gnome-keyring.service \
        ${./basic-service-expected.service}
    '';
  };
}
