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
      waylandDisplay = "wayland-1";
    };

    nmt.script = ''
      serviceFile=home-files/.config/systemd/user/dunst.service

      assertFileExists $serviceFile
      assertFileRegex $serviceFile 'ExecStart=.*/bin/dunst'
      assertFileRegex $serviceFile 'Environment=WAYLAND_DISPLAY=wayland-1'
      assertFileRegex $serviceFile 'BusName=org.freedesktop.Notifications'
      assertFileRegex $serviceFile 'Type=dbus'
      assertFileRegex $serviceFile 'Description=Dunst notification daemon'
      assertFileRegex $serviceFile 'After=graphical-session.target'
      assertFileRegex $serviceFile 'PartOf=graphical-session.target'
    '';
  };
}
