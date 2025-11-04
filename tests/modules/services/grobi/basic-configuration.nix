{ config, ... }:

{
  config = {
    services.grobi = {
      enable = true;
    };

    nmt.script = ''
      assertFileExists home-files/.config/systemd/user/grobi.service
      serviceFile=$(normalizeStorePaths home-files/.config/systemd/user/grobi.service)
      assertFileContent \
        $serviceFile \
        ${./basic-configuration-expected.service}

      assertFileExists home-files/.config/grobi.conf
      assertFileContent \
        home-files/.config/grobi.conf \
        ${./basic-configuration-expected.conf}
    '';
  };
}
