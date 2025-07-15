{ config, ... }:

{
  config = {
    programs.fzf = {
      enable = true;
      colors = {
        bg = "#1e1e1e";
        "bg+" = "#1e1e1e";
        fg = "#d4d4d4";
        "fg+" = "#d4d4d4";
        hl = "#569cd6";
        "hl+" = "#569cd6";
      };
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileExists home-files/.profile
      # Check that fzf color options are set
      assertFileRegex home-files/.profile \
        'FZF_DEFAULT_OPTS'
    '';
  };
}
