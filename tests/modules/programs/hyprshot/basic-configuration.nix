{
  config = {
    programs.hyprshot.enable = true;

    nmt.script = ''
      assertFileExists home-files/.config/hyprshot/hyprshot.conf
    '';
  };
}
