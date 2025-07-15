{ config, ... }:

{
  config = {
    programs.mcfly = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.bashrc \
        'eval.*mcfly.*init bash'
    '';
  };
}
