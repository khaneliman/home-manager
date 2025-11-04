{ config, ... }:

{
  config = {
    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.bashrc \
        'eval.*fzf --bash'
    '';
  };
}
