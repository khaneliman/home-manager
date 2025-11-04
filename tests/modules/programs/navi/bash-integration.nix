{ config, ... }:

{
  config = {
    programs.navi = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.bashrc \
        'if.*SHELLOPTS.*vi|emacs'

      assertFileRegex home-files/.bashrc \
        'eval.*navi widget bash'
    '';
  };
}
