{
  config,
  ...
}:

{
  programs.mpv = {
    enable = true;

    bindings = {
      WHEEL_UP = "seek 10";
      WHEEL_DOWN = "seek -10";
      "Alt+0" = "set window-scale 0.5";
    };

    extraInput = ''
      #           script-binding uosc/video                   #! Video tracks
    '';

    includes = [ "manual.conf" ];

    config = {
      force-window = true;
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };

    scriptOpts = {
      osc = {
        scalewindowed = 2.0;
        vidscale = false;
        visibility = "always";
      };
    };

    profiles = {
      fast = {
        vo = "vdpau";
      };
      "protocol.dvd" = {
        profile-desc = "profile for dvd:// streams";
        alang = "en";
      };
    };

    defaultProfiles = [ "gpu-hq" ];
  };

  nmt.script = ''
    assertFileExists home-files/.config/mpv/mpv.conf
    assertFileContent \
       home-files/.config/mpv/mpv.conf \
       ${./mpv-example-settings-expected-config}
    assertFileExists home-files/.config/mpv/input.conf
    assertFileContent \
       home-files/.config/mpv/input.conf \
       ${./mpv-example-settings-expected-bindings}
    assertFileExists home-files/.config/mpv/script-opts/osc.conf
    assertFileContent \
       home-files/.config/mpv/script-opts/osc.conf \
       ${./mpv-example-settings-expected-osc-opts}
  '';
}
