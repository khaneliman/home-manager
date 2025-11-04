{ config, ... }:

{
  config = {
    programs.rbw = {
      enable = true;
      settings = {
        email = "user@example.com";
        lock_timeout = 300;
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/rbw/config.json
      assertFileContent \
        home-files/.config/rbw/config.json \
        ${./settings-configuration-expected.json}
    '';
  };
}
