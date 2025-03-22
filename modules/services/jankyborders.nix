{ config, lib, pkgs, ... }:
let cfg = config.services.jankyborders;
in {
  meta.maintainers = [ lib.maintainers.khaneliman ];

  options.services.jankyborders = {
    enable = lib.mkEnableOption "jankyborders agent";

    package = lib.mkPackageOption pkgs "jankyborders" { };

    settings = lib.mkOption {
      type = with lib.types; attrsOf (oneOf [ str bool int float ]);
      default = { };
      example = lib.literalExpression ''
                {
                  style=round;
        	        width=6.0;
        	        hidpi="off";
        	        active_color="0xffe2e2e3";
        	        inactive_color="0xff414550";
                }
      '';
      description = ''
        Configuration settings to passed to `borders` in
        {file}`$XDG_CONFIG_HOME/borders/bordersc`. See
        <https://github.com/FelixKratz/JankyBorders>
        for the documentation.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.jankyborders" pkgs
        lib.platforms.darwin)
    ];

    home.packages = lib.mkIf (cfg.package != null) [ cfg.package ];

    xdg.configFile."borders/bordersrc".text = ''
      #!/bin/bash

      options=(
      ${lib.generators.toKeyValue { indent = "  "; } cfg.settings})

      borders "''${options[@]}"
      '';

    launchd.user.agents.jankyborders = {
      serviceConfig.ProgramArguments = [ (lib.getExe cfg.package) ];
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
