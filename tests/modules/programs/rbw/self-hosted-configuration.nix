{ config, ... }:

{
  config = {
    programs.rbw = {
      enable = true;
      settings = {
        email = "user@example.com";
        base_url = "https://bitwarden.example.com/";
        identity_url = "https://identity.example.com/";
        lock_timeout = 600;
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/rbw/config.json
      assertFileContent \
        home-files/.config/rbw/config.json \
        ${./self-hosted-configuration-expected.json}
    '';
  };
}
