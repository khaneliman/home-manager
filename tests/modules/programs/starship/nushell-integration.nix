{ config, ... }:

{
  config = {
    programs.starship = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.nushell.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.config/nushell/config.nu \
        'use.*starship.*nu'
    '';
  };
}
