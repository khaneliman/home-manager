{ lib, ... }:

let
  fakePkgs = {
    stdenv.hostPlatform.system = "x86_64-linux";
  };
in
{
  assertions = [
    (lib.hm.assertions.assertPlatform "programs.example" fakePkgs [ "x86_64-darwin" ])
  ];
}
