{ config, pkgs, ... }:

{
  config = {
    services.keybase = {
      enable = true;
      package = pkgs.keybase;
    };

    nmt.script = ''
      # Test systemd service file is created with correct configuration
      assertFileExists home-files/.config/systemd/user/keybase.service
      assertFileContent \
        home-files/.config/systemd/user/keybase.service \
        ${./keybase-service-expected.service}
    '';
  };
}
