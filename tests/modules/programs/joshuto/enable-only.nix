{
  config = {
    programs.joshuto.enable = true;

    nmt.script = ''
      assertPathNotExists home-files/.config/joshuto/joshuto.toml
      assertPathNotExists home-files/.config/joshuto/keymap.toml
      assertPathNotExists home-files/.config/joshuto/mimetype.toml
      assertPathNotExists home-files/.config/joshuto/theme.toml
    '';
  };
}
