{ config, ... }:

{
  config = {
    programs.fzf = {
      enable = true;
      defaultCommand = "fd --type f";
      defaultOptions = [
        "--height 40%"
        "--border"
        "--layout=reverse"
      ];
    };

    programs.bash.enable = true;

    nmt.script = ''
      # Check that fzf environment variables are set in session vars
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        'export FZF_DEFAULT_COMMAND="fd --type f"'
      assertFileContains home-path/etc/profile.d/hm-session-vars.sh \
        'export FZF_DEFAULT_OPTS="--height 40% --border --layout=reverse"'
    '';
  };
}
