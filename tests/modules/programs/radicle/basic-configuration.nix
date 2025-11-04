{ config, pkgs, ... }:

{
  config = {
    programs.radicle.enable = true;

    nmt.script = ''
      assertFileExists home-files/.radicle/config.json
      assertFileContent \
        home-files/.radicle/config.json \
        ${./basic-configuration.json}
    '';
  };
}
