{ config, pkgs, ... }:

{
  config = {
    programs.rbw = {
      enable = true;
      settings = {
        email = "user@example.com";
        pinentry = pkgs.pinentry-gnome3;
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/rbw/config.json \
        ${./with-pinentry-expected.json}
    '';
  };
}
