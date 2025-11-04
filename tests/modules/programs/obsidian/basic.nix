{ config, ... }:

{
  config = {
    programs.obsidian.enable = true;

    nmt.script = ''
      # Test that obsidian config directory is created
      assertFileExists home-files/.config/obsidian/obsidian.json

      # Test basic obsidian.json structure
      assertFileContains \
        home-files/.config/obsidian/obsidian.json \
        '"vaults"'
    '';
  };
}
