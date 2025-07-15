{ config, ... }:

{
  config = {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.bashrc \
        'eval.*zoxide.*init bash'
    '';
  };
}
