{
  config = {
    programs.librewolf = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
          settings = {
            "browser.newtabpage.enabled" = false;
            "browser.startup.homepage" = "about:blank";
          };
        };
        work = {
          id = 1;
          name = "work";
          settings = {
            "extensions.autoDisableScopes" = 0;
          };
        };
      };
    };

    nmt.script = ''
      # Test profiles.ini creation
      assertFileExists home-files/.librewolf/profiles.ini
      assertFileRegex home-files/.librewolf/profiles.ini 'Name=default'
      assertFileRegex home-files/.librewolf/profiles.ini 'Name=work'
      assertFileRegex home-files/.librewolf/profiles.ini 'Default=1'

      # Test profile-specific prefs.js files
      assertFileExists home-files/.librewolf/default/prefs.js
      assertFileRegex home-files/.librewolf/default/prefs.js 'browser\.newtabpage\.enabled.*false'
      assertFileRegex home-files/.librewolf/default/prefs.js 'browser\.startup\.homepage.*about:blank'

      assertFileExists home-files/.librewolf/work/prefs.js
      assertFileRegex home-files/.librewolf/work/prefs.js 'extensions\.autoDisableScopes.*0'
    '';
  };
}
