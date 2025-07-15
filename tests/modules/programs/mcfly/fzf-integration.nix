{ config, ... }:

{
  config = {
    programs.mcfly = {
      enable = true;
      enableBashIntegration = true;
      fzf.enable = true;
    };

    programs.bash.enable = true;

    nmt.script = ''
      # Test both mcfly and mcfly-fzf initialization
      assertFileRegex home-files/.bashrc \
        'eval.*mcfly.*init bash'

      assertFileRegex home-files/.bashrc \
        'eval.*mcfly-fzf.*init bash'

      # Test interactive shell check for fzf
      assertFileRegex home-files/.bashrc \
        'if.*\$- =~ i.*then'
    '';
  };
}
