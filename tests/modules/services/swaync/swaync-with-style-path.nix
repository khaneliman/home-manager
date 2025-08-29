{ config, pkgs, ... }:

{
  services.swaync = {
    enable = true;
    package = config.lib.test.mkStubPackage {
      name = "swaync";
      outPath = "@swaync@";
    };

    # Test path input (should become { source = path; })
    style = pkgs.writeText "custom-style.css" ''
      .custom-notification {
        color: red;
        font-weight: bold;
      }
    '';
  };

  nmt.script = ''
    # Test that the style.css file was created as a symlink to the source
    styleFile=home-files/.config/swaync/style.css

    assertFileExists $styleFile

    # The content should match our writeText content
    assertFileContains $styleFile ".custom-notification"
    assertFileContains $styleFile "color: red"
    assertFileContains $styleFile "font-weight: bold"
  '';
}
