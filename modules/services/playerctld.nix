{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.playerctld;

in
{
  meta.maintainers = [ lib.hm.maintainers.fendse ];

  options.services.playerctld = {
    enable = lib.mkEnableOption "playerctld daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.playerctl;
      defaultText = lib.literalExpression "pkgs.playerctl";
      description = "The playerctl package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.playerctld" pkgs lib.platforms.linux)
    ];

    home.packages = [ cfg.package ];

    systemd.user.services.playerctld = {
      Unit.Description = "MPRIS media player daemon";

      Install.WantedBy = [ "default.target" ];

      Service = {
        ExecStart = "${cfg.package}/bin/playerctld";
        Type = "dbus";
        BusName = "org.mpris.MediaPlayer2.playerctld";
      };
    };
  };
}
