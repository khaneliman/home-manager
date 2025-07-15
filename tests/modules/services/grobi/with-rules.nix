{ config, ... }:

{
  config = {
    services.grobi = {
      enable = true;
      rules = [
        {
          name = "Home";
          outputs_connected = [ "DP-2" ];
          configure_single = "DP-2";
          primary = true;
          atomic = true;
        }
        {
          name = "Mobile";
          outputs_disconnected = [ "DP-2" ];
          configure_single = "eDP-1";
          primary = true;
          atomic = true;
        }
      ];
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/grobi.service
      assertFileExists home-files/.config/grobi.conf
      assertFileContent \
        home-files/.config/grobi.conf \
        ${./with-rules-expected.conf}
    '';
  };
}
