{ config, ... }:

{
  config = {
    programs.fd = {
      enable = true;
      hidden = true;
      extraOptions = [
        "--no-ignore"
        "--absolute-path"
      ];
    };

    programs.bash.enable = true;
    programs.zsh.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.bashrc \
        'alias fd=.*fd --hidden --no-ignore --absolute-path'

      assertFileRegex home-files/.zshrc \
        'alias.*fd=.*fd --hidden --no-ignore --absolute-path'
    '';
  };
}
