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
      assertFileExists home-files/.profile
      # Check that fzf environment variables are set
      assertFileRegex home-files/.profile \
        'FZF_DEFAULT_COMMAND'
      assertFileRegex home-files/.profile \
        'FZF_DEFAULT_OPTS'
    '';
  };
}
