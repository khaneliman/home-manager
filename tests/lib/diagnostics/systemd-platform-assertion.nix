{ lib, ... }:

let
  fakePkgs.stdenv.hostPlatform.system = "x86_64-darwin";
in
{
  assertions = [
    (lib.hm.assertions.assertPlatform {
      module = "systemd";
      optionPath = [
        "systemd"
        "user"
      ];
    } fakePkgs [ "x86_64-linux" ])
  ];
}
