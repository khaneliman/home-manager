{ config, ... }:

{
  config = {
    services.grobi = {
      enable = true;
      executeAfter = [
        "setxkbmap dvorak"
        "xrandr --dpi 96"
      ];
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/grobi.service
      assertFileExists home-files/.config/grobi.conf
      assertFileContent \
        home-files/.config/grobi.conf \
        ${./with-execute-after-expected.conf}
    '';
  };
}
