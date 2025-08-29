{ config, ... }:

{
  services.swaync = {
    enable = true;
    package = config.lib.test.mkStubPackage {
      name = "swaync";
      outPath = "@swaync@";
    };

    # Test string input (should become { text = "..."; })
    style = ''
      .notification-row {
        outline: none;
        background: #333;
      }

      .notification {
        border-radius: 12px;
        margin: 6px 12px;
      }
    '';
  };

  nmt.script = ''
    serviceFile=home-files/.config/systemd/user/swaync.service
    serviceFile=$(normalizeStorePaths $serviceFile)

    assertFileContent \
      $serviceFile \
      ${builtins.toFile "swaync.service" ''
        [Install]
        WantedBy=graphical-session.target

        [Service]
        BusName=org.freedesktop.Notifications
        ExecStart=@swaync@/bin/swaync
        Restart=on-failure
        Type=dbus

        [Unit]
        After=graphical-session.target
        ConditionEnvironment=WAYLAND_DISPLAY
        Description=Swaync notification daemon
        Documentation=https://github.com/ErikReider/SwayNotificationCenter
        PartOf=graphical-session.target
        X-Restart-Triggers=/nix/store/00000000000000000000000000000000-config.json
        X-Restart-Triggers=/nix/store/00000000000000000000000000000000-hm_swayncstyle.css
      ''}

    # Test that the style.css file was created with text content
    styleFile=home-files/.config/swaync/style.css

    assertFileExists $styleFile
    assertFileContains $styleFile ".notification-row"
    assertFileContains $styleFile "background: #333"
    assertFileContains $styleFile "border-radius: 12px"

    # Test that config.json was also created
    configFile=home-files/.config/swaync/config.json
    assertFileExists $configFile
  '';
}
