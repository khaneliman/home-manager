{ config, ... }:

{
  config = {
    programs.mcfly = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fish.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.config/fish/config.fish \
        'mcfly init fish.*source'
    '';
  };
}
