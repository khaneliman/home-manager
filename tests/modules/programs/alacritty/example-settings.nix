{
  programs.alacritty = {
    enable = true;
    settings = {
      window.dimensions = {
        lines = 3;
        columns = 200;
      };

      keyboard.bindings = [
        {
          key = "K";
          mods = "Control";
          chars = "\\u000c";
        }
      ];
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/alacritty/alacritty.toml
    assertFileContent \
      home-files/.config/alacritty/alacritty.toml \
      ${./example-settings-expected.toml}
  '';
}
