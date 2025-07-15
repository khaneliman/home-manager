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
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
        {
          id = "dcpihecpambacapedldabdbpakmachpb";
          updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
        }
        {
          id = "aaaaaaaaaabbbbbbbbbbccccccccccdd";
          crxPath = "/home/share/extension.crx";
          version = "1.0";
        }
      ];
    };

    nmt.script = ''
      configDir="${
        if pkgs.stdenv.isDarwin then "Library/Application Support/Chromium" else ".config/chromium"
      }"

      # Test that extension JSON files are created
      assertFileExists "home-files/$configDir/External Extensions/cjpalhdlnbpafiamejdnhcphjbkeiagm.json"
      assertFileExists "home-files/$configDir/External Extensions/dcpihecpambacapedldabdbpakmachpb.json" 
      assertFileExists "home-files/$configDir/External Extensions/aaaaaaaaaabbbbbbbbbbccccccccccdd.json"

      # Test content of web store extension
      ublock_config="home-files/$configDir/External Extensions/cjpalhdlnbpafiamejdnhcphjbkeiagm.json"
      assertFileRegex "$ublock_config" '"external_update_url":"https://clients2.google.com/service/update2/crx"'

      # Test content of external update URL extension  
      paywall_config="home-files/$configDir/External Extensions/dcpihecpambacapedldabdbpakmachpb.json"
      assertFileRegex "$paywall_config" '"external_update_url":"https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml"'

      # Test content of local crx extension
      local_config="home-files/$configDir/External Extensions/aaaaaaaaaabbbbbbbbbbccccccccccdd.json"
      assertFileRegex "$local_config" '"external_crx":"/home/share/extension.crx"'
      assertFileRegex "$local_config" '"external_version":"1.0"'
    '';
  };
}
