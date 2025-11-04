{ config, pkgs, ... }:

{
  config = {
    programs.brave = {
      enable = true;
      package = config.lib.test.mkStubPackage {
        name = "brave-test";
        buildScript = "mkdir -p $out/bin; echo '#!/bin/sh' > $out/bin/brave; chmod +x $out/bin/brave";
      };
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      ];
    };

    nmt.script = ''
      # Test brave browser package is installed
      assertFileExists home-path/bin/brave

      # Test brave-specific config directory
      configDir="${
        if pkgs.stdenv.isDarwin then
          "Library/Application Support/BraveSoftware/Brave-Browser"
        else
          ".config/BraveSoftware/Brave-Browser"
      }"

      # Test that extension JSON file is created
      assertFileExists "home-files/$configDir/External Extensions/nngceckbapebfimnlniiiahkandclblb.json"

      # Test content of extension config
      bitwarden_config="home-files/$configDir/External Extensions/nngceckbapebfimnlniiiahkandclblb.json"
      assertFileRegex "$bitwarden_config" '"external_update_url":"https://clients2.google.com/service/update2/crx"'
    '';
  };
}
