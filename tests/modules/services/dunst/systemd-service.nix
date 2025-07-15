{
  config,
  lib,
  ...
}:

{
  config = {
    services.dunst = {
      enable = true;
      package = config.lib.test.mkStubPackage {
        outPath = "@dunst@";
        name = "dunst";
      };
    };

    nmt.script = ''
      assertFileContent \
        home-files/.config/systemd/user/dunst.service \
        ${./systemd-service-expected.service}
    '';
  };
}
