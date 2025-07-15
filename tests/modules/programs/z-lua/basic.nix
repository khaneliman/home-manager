{ config, ... }:

{
  config = {
    programs.z-lua = {
      enable = true;
      package = config.lib.test.mkStubPackage { };
      options = [
        "enhanced"
        "once"
      ];
      enableBashIntegration = true;
      enableAliases = true;
    };

    programs.bash.enable = true;

    nmt.script = ''
      assertFileExists home-path/.bashrc
      assertFileContains home-path/.bashrc 'eval "$(.*z --init bash enhanced once)"'
    '';
  };
}
