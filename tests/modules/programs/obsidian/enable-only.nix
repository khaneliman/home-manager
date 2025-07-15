{
  config = {
    programs.obsidian.enable = true;

    nmt.script = ''
      # With no vaults configured, only main config should exist
      assertFileExists home-files/.config/obsidian/obsidian.json
      assertFileContent home-files/.config/obsidian/obsidian.json ${builtins.toFile "expected-obsidian.json" ''
        {
          "updateDisabled": true,
          "vaults": {}
        }
      ''}
    '';
  };
}
