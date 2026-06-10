{ lib }:

{
  assertPlatform =
    module: pkgs: platforms:
    let
      optionPath = lib.splitString "." module;
      platformsStr = lib.concatStringsSep "\n" (map (p: "  - ${p}") (lib.sort (a: b: a < b) platforms));
    in
    {
      assertion = lib.elem pkgs.stdenv.hostPlatform.system platforms;
      relatedOptions = [
        (optionPath ++ [ "enable" ])
        optionPath
      ];
      message = ''
        The module ${module} does not support your platform. It only supports

        ${platformsStr}'';
    };
}
