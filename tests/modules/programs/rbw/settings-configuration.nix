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
      assertFileContent \
        home-files/.config/rbw/config.json \
        ${./settings-configuration-expected.json}
    '';
  };
}
