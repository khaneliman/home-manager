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
      assertFileRegex home-files/.profile \
        'FZF_CTRL_T_COMMAND.*fd --type f'
      assertFileRegex home-files/.profile \
        'FZF_CTRL_T_OPTS.*--preview .head {}'
      assertFileRegex home-files/.profile \
        'FZF_ALT_C_COMMAND.*fd --type d'
      assertFileRegex home-files/.profile \
        'FZF_ALT_C_OPTS.*--preview .tree -C {} | head -200'
      assertFileRegex home-files/.profile \
        'FZF_CTRL_R_OPTS.*--sort --exact'
    '';
  };
}
