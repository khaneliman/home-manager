modulePath:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = lib.getAttrFromPath modulePath config;

  firefoxMockOverlay = import ./setup-firefox-mock-overlay.nix modulePath;
in
{
  imports = [ firefoxMockOverlay ];

  config = lib.mkIf (config.test.enableBig && !pkgs.stdenv.hostPlatform.isDarwin) (
    {
      home.stateVersion = "24.11"; # Pre-25.11
      xdg.enable = true;
    }
    // lib.setAttrByPath modulePath {
      enable = true;
      profiles.default = {
        id = 0;
        isDefault = true;
        settings = {
          "general.smoothScroll" = false;
        };
      };
    }
    // {
      nmt.script = ''
        # Verify configPath uses legacy location
        configPath="${cfg.configPath}"
        echo "configPath: $configPath"

        # Should be .mozilla/firefox
        if [[ "$configPath" != ".mozilla/firefox" ]]; then
          fail "Expected legacy configPath (.mozilla/firefox), got: $configPath"
        fi

        # Verify profiles.ini is in legacy location
        assertFileExists "home-files/.mozilla/firefox/profiles.ini"

        # Verify profile directory is in legacy location
        assertDirectoryExists "home-files/.mozilla/firefox/default"

        # Verify user.js in legacy location
        assertFileExists "home-files/.mozilla/firefox/default/user.js"
      '';
    }
  );
}
