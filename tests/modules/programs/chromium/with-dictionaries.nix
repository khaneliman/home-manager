{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.chromium = {
      enable = true;
      package = config.lib.test.mkStubPackage {
        name = "chromium-test";
        buildScript = "mkdir -p $out/bin; echo '#!/bin/sh' > $out/bin/chromium; chmod +x $out/bin/chromium";
      };
      dictionaries = [
        (config.lib.test.mkStubPackage {
          name = "hunspell-dict-en-us";
          buildScript = ''
            # Dictionary packages are single files, not directories
            echo "en_US dictionary binary data" > $out
          '';
          extraAttrs = {
            passthru.dictFileName = "en_US.dic";
          };
        })
        (config.lib.test.mkStubPackage {
          name = "hunspell-dict-es-es";
          buildScript = ''
            # Dictionary packages are single files, not directories
            echo "es_ES dictionary binary data" > $out
          '';
          extraAttrs = {
            passthru.dictFileName = "es_ES.dic";
          };
        })
      ];
      nativeMessagingHosts = [
        (config.lib.test.mkStubPackage {
          name = "plasma-browser-integration";
          buildScript = ''
            mkdir -p $out/etc/chromium/native-messaging-hosts
            echo '{"name": "org.kde.plasma.browser_integration"}' > $out/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json
          '';
        })
      ];
    };

    nmt.script = ''
      configDir="${
        if pkgs.stdenv.isDarwin then "Library/Application Support/Chromium" else ".config/chromium"
      }"

      # Test that dictionary files are linked correctly
      assertFileExists "home-files/$configDir/Dictionaries/en_US.dic"
      assertFileExists "home-files/$configDir/Dictionaries/es_ES.dic"

      # Test native messaging hosts directory
      assertFileExists "home-files/$configDir/NativeMessagingHosts/org.kde.plasma.browser_integration.json"

      # Test content of native messaging host file
      assertFileRegex "home-files/$configDir/NativeMessagingHosts/org.kde.plasma.browser_integration.json" '"name": "org.kde.plasma.browser_integration"'
    '';
  };
}
