{
  config = {
    programs.librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "privacy.resistFingerprinting" = false;
        "network.cookie.cookieBehavior" = 1;
        "browser.startup.homepage" = "https://start.duckduckgo.com";
      };
    };

    nmt.script = ''
      assertFileExists home-files/.librewolf/librewolf.overrides.cfg
      assertFileRegex home-files/.librewolf/librewolf.overrides.cfg 'defaultPref.*webgl\.disabled.*false'
      assertFileRegex home-files/.librewolf/librewolf.overrides.cfg 'defaultPref.*privacy\.resistFingerprinting.*false'
      assertFileRegex home-files/.librewolf/librewolf.overrides.cfg 'defaultPref.*network\.cookie\.cookieBehavior.*1'
      assertFileRegex home-files/.librewolf/librewolf.overrides.cfg 'defaultPref.*browser\.startup\.homepage.*duckduckgo'
    '';
  };
}
