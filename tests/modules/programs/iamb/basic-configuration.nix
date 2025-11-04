{ config, pkgs, ... }:
{
  config = {
    programs.iamb = {
      enable = true;
      settings.test = "string";
    };

    nmt.script =
      let
        configDir =
          if pkgs.stdenv.isDarwin && !config.xdg.enable then "Library/Application Support" else ".config";
      in
      ''
        assertFileExists "home-files/${configDir}/iamb/config.toml"
      '';
  };
}
