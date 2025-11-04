{ config, ... }:

{
  config = {
    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/gnome-keyring.service
      assertFileContent \
        home-files/.config/systemd/user/gnome-keyring.service \
        ${./custom-components-expected.service}
    '';
  };
}
