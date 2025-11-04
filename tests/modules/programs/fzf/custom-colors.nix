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
      # Check that fzf color options are set in session variables
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        'export FZF_DEFAULT_OPTS="--color bg:#1e1e1e,bg+:#1e1e1e,fg:#d4d4d4,fg+:#d4d4d4,hl:#569cd6,hl+:#569cd6"'
    '';
  };
}
