{ config, ... }:

{
  config = {
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    programs.fish.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.config/fish/config.fish \
        'zoxide init fish.*source'
    '';
  };
}
