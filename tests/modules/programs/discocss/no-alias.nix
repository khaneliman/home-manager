{ config, ... }:

{
  config = {
    programs.discocss = {
      enable = true;
      discordAlias = false;
    };

    nmt.script = ''
      assertFileExists home-files/.config/discocss/custom.css
    '';
  };
}
