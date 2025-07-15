{
  config = {
    programs.joshuto = {
      enable = true;
      settings = {
        scroll_offset = 6;
        use_trash = true;
      };
      keymap = {
        default_view = {
          keymap = [
            {
              keys = [ "escape" ];
              commands = [ "escape" ];
            }
            {
              keys = [ "ctrl+c" ];
              commands = [ "escape" ];
            }
          ];
        };
      };
      mimetype = {
        class = {
          audio_default = [
            {
              command = "mpv";
              args = [ "--" ];
            }
          ];
        };
      };
      theme = {
        regular = {
          fg = "light_yellow";
          bg = "reset";
        };
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/joshuto/joshuto.toml
      assertFileContent home-files/.config/joshuto/joshuto.toml ${builtins.toFile "expected-joshuto.toml" ''
        scroll_offset = 6
        use_trash = true
      ''}

      assertFileExists home-files/.config/joshuto/keymap.toml
      assertFileRegex home-files/.config/joshuto/keymap.toml 'commands.*escape'
      assertFileRegex home-files/.config/joshuto/keymap.toml 'keys.*escape'

      assertFileExists home-files/.config/joshuto/mimetype.toml
      assertFileRegex home-files/.config/joshuto/mimetype.toml 'audio_default'
      assertFileRegex home-files/.config/joshuto/mimetype.toml 'mpv'

      assertFileExists home-files/.config/joshuto/theme.toml
      assertFileRegex home-files/.config/joshuto/theme.toml 'light_yellow'
    '';
  };
}
