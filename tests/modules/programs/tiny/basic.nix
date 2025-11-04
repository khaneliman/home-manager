{ config, ... }:

{
  config = {
    programs.tiny = {
      enable = true;
      package = config.lib.test.mkStubPackage { };
      settings = {
        servers = [
          {
            addr = "irc.libera.chat";
            port = 6697;
            tls = true;
            realname = "John Doe";
            nicks = [ "tinyuser" ];
          }
        ];
      };
    };

    nmt.script = ''
      assertFileExists home-path/.config/tiny/config.yml
      assertFileContains home-path/.config/tiny/config.yml "irc.libera.chat"
    '';
  };
}
