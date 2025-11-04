{ config, ... }:

let
  testPlugin = config.lib.test.mkStubPackage {
    name = "ruby-build";
    version = "20221225";
  };
in
{
  programs.rbenv = {
    enable = true;
    plugins = [
      {
        name = "ruby-build";
        src = testPlugin;
      }
    ];
    enableBashIntegration = false;
    enableZshIntegration = false;
    enableFishIntegration = false;
  };

  nmt.script = ''
    assertFileExists home-files/.rbenv/plugins
    assertFileExists home-files/.rbenv/plugins/ruby-build
  '';
}
