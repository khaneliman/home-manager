{ config, ... }:

{
  config = {
    programs.fzf = {
      enable = true;
      tmux = {
        enableShellIntegration = true;
        shellIntegrationOptions = [
          "-d"
          "40%"
        ];
      };
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.profile \
        'FZF_TMUX.*1'
      assertFileRegex home-files/.profile \
        'FZF_TMUX_OPTS.*-d 40%'
    '';
  };
}
