{
  config,
  ...
}:

let
  stub = import ./stub.nix { inherit config; };
in

{
  config = {
    services.dunst = {
      enable = true;
      package = stub.dunstStubPackage;

      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          transparency = 10;
          frame_color = "#eceff1";
          font = "Droid Sans 9";
          follow = "mouse";
          indicate_hidden = true;
          line_height = 0;
          notification_height = 0;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          frame_width = 2;
          separator_color = "frame";
          startup_notification = false;
          dmenu = "/usr/bin/dmenu -p dunst:";
          browser = "/usr/bin/firefox -new-tab";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          corner_radius = 0;
          force_xinerama = false;
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action";
          mouse_right_click = "close_all";
        };

        urgency_low = {
          background = "#222222";
          foreground = "#888888";
          timeout = 10;
        };

        urgency_normal = {
          background = "#37474f";
          foreground = "#eceff1";
          timeout = 10;
        };

        urgency_critical = {
          background = "#900000";
          foreground = "#ffffff";
          frame_color = "#ff0000";
          timeout = 0;
        };
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/dunst/dunstrc \
        ${./config-generation-expected.ini}
    '';
  };
}
