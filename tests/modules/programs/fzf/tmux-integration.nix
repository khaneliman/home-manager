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
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        'export FZF_TMUX="1"'
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        'export FZF_TMUX_OPTS="-d 40%"'
    '';
  };
}
