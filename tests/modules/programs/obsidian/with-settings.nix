{ config, ... }:

{
  config = {
    programs.obsidian = {
      enable = true;

      defaultSettings = {
        app = {
          showLineNumber = true;
          newFileLocation = "folder";
        };

        appearance = {
          theme = "obsidian";
          baseFontSize = 16;
        };

        corePlugins = [
          "backlink"
          "file-explorer"
          "global-search"
          "outline"
        ];
      };

      vaults = {
        configured-vault = {
          target = "Notes/ConfiguredVault";
          settings = {
            app = {
              showLineNumber = false;
              newLinkFormat = "relative";
            };

            hotkeys = {
              "app:go-forward" = [
                {
                  modifiers = [ "Ctrl" ];
                  key = "ArrowRight";
                }
              ];
            };
          };
        };
      };
    };

    nmt.script = ''
      # Test vault app.json contains both default and vault-specific settings
      assertFileExists home-files/Notes/ConfiguredVault/.obsidian/app.json
      assertFileContains \
        home-files/Notes/ConfiguredVault/.obsidian/app.json \
        '"showLineNumber":false'
        
      assertFileContains \
        home-files/Notes/ConfiguredVault/.obsidian/app.json \
        '"newLinkFormat":"relative"'

      # Test appearance.json contains default settings
      assertFileExists home-files/Notes/ConfiguredVault/.obsidian/appearance.json
      assertFileContains \
        home-files/Notes/ConfiguredVault/.obsidian/appearance.json \
        '"theme":"obsidian"'
        
      assertFileContains \
        home-files/Notes/ConfiguredVault/.obsidian/appearance.json \
        '"baseFontSize":16'

      # Test core-plugins.json contains specified plugins
      assertFileExists home-files/Notes/ConfiguredVault/.obsidian/core-plugins.json
      assertFileContains \
        home-files/Notes/ConfiguredVault/.obsidian/core-plugins.json \
        '"backlink"'
        
      assertFileContains \
        home-files/Notes/ConfiguredVault/.obsidian/core-plugins.json \
        '"file-explorer"'

      # Test hotkeys.json contains configured hotkeys
      assertFileExists home-files/Notes/ConfiguredVault/.obsidian/hotkeys.json
      assertFileContains \
        home-files/Notes/ConfiguredVault/.obsidian/hotkeys.json \
        '"app:go-forward"'
        
      assertFileContains \
        home-files/Notes/ConfiguredVault/.obsidian/hotkeys.json \
        '"key":"ArrowRight"'
    '';
  };
}
