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
      home.stateVersion = "25.11";
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
        # Verify configPath uses XDG location
        configPath="${cfg.configPath}"
        echo "configPath: $configPath"

        # Should contain .config/firefox or $XDG_CONFIG_HOME/firefox
        if [[ "$configPath" != *".config/firefox"* ]]; then
          fail "Expected configPath to use XDG location (.config/firefox), got: $configPath"
        fi

        # Verify profiles.ini is in XDG location
        assertFileExists "home-files/.config/firefox/profiles.ini"

        # Verify profile directory is in XDG location
        assertDirectoryExists "home-files/.config/firefox/default"

        # Verify user.js in XDG location
        assertFileExists "home-files/.config/firefox/default/user.js"
      '';
    }
  );
}
