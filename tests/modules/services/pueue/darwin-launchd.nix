{ config, ... }:

{
  services.pueue = {
    enable = true;
    package = config.lib.test.mkStubPackage { outPath = "@pueue@"; };
    settings = {
      daemon = {
        default_parallel_tasks = 1;
      };
    };
  };

  nmt.script = ''
    serviceFile="Library/LaunchAgents/org.nix-community.home.pueued.plist"
    serviceFileNormalized="$(normalizeStorePaths "$serviceFile")"
    assertFileExists "$serviceFile"
    assertFileContent "$serviceFileNormalized" ${./darwin-launchd-expected.plist}

    configFile="Library/Application Support/pueue/pueue.yml"
    assertFileExists "$configFile"
  '';
}
