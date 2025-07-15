{
  config,
  lib,
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

      iconTheme = {
        name = "Adwaita";
        package = config.lib.test.mkStubPackage { outPath = "@adwaita-icon-theme@"; };
        size = "24x24";
      };

      settings = {
        global = {
          # Keep other settings minimal to focus on icon path testing
          width = 300;
          height = 300;
        };
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/dunst/dunstrc \
        ${./icon-theme-expected.ini}
    '';
  };
}
