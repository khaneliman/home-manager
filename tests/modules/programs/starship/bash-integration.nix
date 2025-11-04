{ config, ... }:

{
  config = {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileRegex home-files/.bashrc \
        'if.*TERM.*dumb'

      assertFileRegex home-files/.bashrc \
        'eval.*starship.*init bash --print-full-init'
    '';
  };
}
