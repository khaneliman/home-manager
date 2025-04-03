{
  config,
  lib,
  pkgs,
  ...
}:

let

  cfg = config.services.taffybar;

in
{
  meta.maintainers = [ lib.maintainers.rycee ];

  options = {
    services.taffybar = {
      enable = lib.mkEnableOption "Taffybar";

      package = lib.mkOption {
        default = pkgs.taffybar;
        defaultText = lib.literalExpression "pkgs.taffybar";
        type = lib.types.package;
        example = lib.literalExpression "pkgs.taffybar";
        description = "The package to use for the Taffybar binary.";
      };
    };
  };

  config = lib.mkIf config.services.taffybar.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.taffybar" pkgs lib.platforms.linux)
    ];

    systemd.user.services.taffybar = {
      Unit = {
        Description = "Taffybar desktop bar";
        PartOf = [ "tray.target" ];
        StartLimitBurst = 5;
        StartLimitIntervalSec = 10;
      };

      Service = {
        Type = "dbus";
        BusName = "org.taffybar.Bar";
        ExecStart = "${cfg.package}/bin/taffybar";
        Restart = "on-failure";
        RestartSec = "2s";
      };

      Install = {
        WantedBy = [ "tray.target" ];
      };
    };

    xsession.importedVariables = [ "GDK_PIXBUF_MODULE_FILE" ];
  };
}
