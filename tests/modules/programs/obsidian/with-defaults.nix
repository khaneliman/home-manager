{
  config = {
    programs.obsidian = {
      enable = true;
      defaultSettings = {
        app = {
          legacyEditor = true;
          showLineNumber = true;
        };
        appearance = {
          baseFontSize = 16;
        };
        corePlugins = [
          "backlink"
          "graph"
          "switcher"
        ];
      };
      vaults = {
        test = {
          target = "TestVault";
        };
      };
    };

    nmt.script = ''
      # Test vault inherits default settings
      assertFileExists home-files/TestVault/.obsidian/app.json
      assertFileRegex home-files/TestVault/.obsidian/app.json 'legacyEditor.*true'
      assertFileRegex home-files/TestVault/.obsidian/app.json 'showLineNumber.*true'

      assertFileExists home-files/TestVault/.obsidian/appearance.json
      assertFileRegex home-files/TestVault/.obsidian/appearance.json 'baseFontSize.*16'

      assertFileExists home-files/TestVault/.obsidian/core-plugins.json
      assertFileRegex home-files/TestVault/.obsidian/core-plugins.json 'backlink'
      assertFileRegex home-files/TestVault/.obsidian/core-plugins.json 'graph'
      assertFileRegex home-files/TestVault/.obsidian/core-plugins.json 'switcher'
    '';
  };
}
