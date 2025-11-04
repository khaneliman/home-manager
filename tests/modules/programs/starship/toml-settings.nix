{ config, ... }:

{
  config = {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        scan_timeout = 10;
        character = {
          success_symbol = "➜";
          error_symbol = "➜";
        };
        aws.disabled = true;
        gcloud.disabled = true;
      };
    };

    nmt.script = ''
      assertFileExists home-files/.config/starship.toml
      assertFileContent \
        home-files/.config/starship.toml \
        ${./toml-settings-expected.toml}
    '';
  };
}
