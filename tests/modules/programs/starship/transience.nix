{ config, ... }:

{
  config = {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableTransience = true;
    };

    programs.fish.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.config/fish/config.fish \
        'starship init fish.*source'

      assertFileRegex home-files/.config/fish/config.fish \
        'enable_transience'
    '';
  };
}
