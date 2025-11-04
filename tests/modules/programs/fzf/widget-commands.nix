{ config, ... }:

{
  config = {
    programs.fzf = {
      enable = true;
      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [ "--preview 'head {}'" ];
      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [ "--preview 'tree -C {} | head -200'" ];
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        'export FZF_CTRL_T_COMMAND="fd --type f"'
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        "export FZF_CTRL_T_OPTS=\"--preview 'head {}'\""
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        'export FZF_ALT_C_COMMAND="fd --type d"'
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        "export FZF_ALT_C_OPTS=\"--preview 'tree -C {} | head -200'\""
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        'export FZF_CTRL_R_OPTS="--sort --exact"'
    '';
  };
}
