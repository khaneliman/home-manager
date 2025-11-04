{ config, ... }:

{
  config = {
    programs.senpai = {
      enable = true;
      package = config.lib.test.mkStubPackage { };
      config = {
        address = "irc.libera.chat";
        nickname = "Guest123456";
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/senpai/senpai.scfg
      assertFileContent \
        home-files/.config/senpai/senpai.scfg \
        ${./empty-settings-expected.conf}
    '';
  };
}
