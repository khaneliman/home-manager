{
  config,
  lib,
  ...
}:

{
  config = {
    services.dunst = {
      enable = true;
      package = config.lib.test.mkStubPackage { outPath = "@dunst@"; };
      waylandDisplay = "wayland-1";
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/dunst.service \
        ${./wayland-display-expected.service}
    '';
  };
}
