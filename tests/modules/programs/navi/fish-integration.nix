{ config, ... }:

{
  config = {
    programs.navi = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fish.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.config/fish/config.fish \
        'navi widget fish.*source'
    '';
  };
}
