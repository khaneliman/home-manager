{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.waylogout = {
      enable = true;
      package = config.lib.test.mkStubPackage { };
      settings = {
        color = "808080";
        poweroff-command = "systemctl poweroff";
        reboot-command = "systemctl reboot";
      };
    };

    nmt.script = ''
      assertFileExists home-path/.config/waylogout/config
      assertFileContains home-path/.config/waylogout/config "color=808080"
      assertFileContains home-path/.config/waylogout/config "poweroff-command=systemctl poweroff"
    '';
  };
}
