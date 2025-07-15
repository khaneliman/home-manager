{ config, ... }:

{
  config = {
    programs.urxvt = {
      enable = true;
      package = config.lib.test.mkStubPackage { };
      fonts = [ "xft:Droid Sans Mono:size=9" ];
      keybindings = {
        "Shift-Control-C" = "eval:selection_to_clipboard";
        "Shift-Control-V" = "eval:paste_clipboard";
      };
    };

    nmt.script = ''
      assertFileExists home-path/.Xresources
      assertFileContains home-path/.Xresources "URxvt.font"
      assertFileContains home-path/.Xresources "URxvt.keysym.Shift-Control-C"
    '';
  };
}
