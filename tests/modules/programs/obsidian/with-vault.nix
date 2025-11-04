{ config, ... }:

{
  config = {
    programs.obsidian = {
      enable = true;
      vaults = {
        personal = {
          target = "Documents/ObsidianVault";
          settings = {
            app = {
              legacyEditor = false;
              livePreview = true;
            };
            appearance = {
              theme = "obsidian";
              translucency = false;
            };
          };
        };
      };
    };

    nmt.script = ''
      # Test main obsidian config
      assertFileExists home-files/.config/obsidian/obsidian.json
      assertFileRegex home-files/.config/obsidian/obsidian.json 'Documents/ObsidianVault'
      assertFileRegex home-files/.config/obsidian/obsidian.json 'updateDisabled.*true'

      # Test vault configuration files
      assertFileExists home-files/Documents/ObsidianVault/.obsidian/app.json
      assertFileRegex home-files/Documents/ObsidianVault/.obsidian/app.json 'legacyEditor.*false'
      assertFileRegex home-files/Documents/ObsidianVault/.obsidian/app.json 'livePreview.*true'

      assertFileExists home-files/Documents/ObsidianVault/.obsidian/appearance.json
      assertFileRegex home-files/Documents/ObsidianVault/.obsidian/appearance.json 'theme.*obsidian'
      assertFileRegex home-files/Documents/ObsidianVault/.obsidian/appearance.json 'translucency.*false'

      # Test core plugins and hotkeys files are created
      assertFileExists home-files/Documents/ObsidianVault/.obsidian/core-plugins.json
      assertFileExists home-files/Documents/ObsidianVault/.obsidian/core-plugins-migration.json
      assertFileExists home-files/Documents/ObsidianVault/.obsidian/hotkeys.json
    '';
  };
}
