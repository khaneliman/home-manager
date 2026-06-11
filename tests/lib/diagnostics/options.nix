{ lib, ... }:

{
  options = {
    assertions = lib.mkOption {
      type = lib.types.listOf lib.types.unspecified;
      internal = true;
      default = [ ];
    };

    warnings = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      internal = true;
      default = [ ];
    };

    programs.example.enable = lib.mkEnableOption "example";
    systemd.user.enable = lib.mkEnableOption "systemd user services";
  };
}
