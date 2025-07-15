{ config, ... }:

{
  config = {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fish.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.config/fish/config.fish \
        'if test.*TERM.*dumb'

      assertFileRegex home-files/.config/fish/config.fish \
        'starship init fish.*source'
    '';
  };
}
