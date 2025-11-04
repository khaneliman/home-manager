{ config, ... }:

{
  config = {
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.nushell.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.config/nushell/config.nu \
        'source.*zoxide.*nushell'
    '';
  };
}
