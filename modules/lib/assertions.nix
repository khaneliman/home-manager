{ lib }:

{
  assertPlatform =
    moduleOrAttrs: pkgs: platforms:
    let
      attrs =
        if lib.isAttrs moduleOrAttrs then
          moduleOrAttrs
        else
          {
            module = moduleOrAttrs;
          };

      optionPath = attrs.optionPath or (lib.splitString "." attrs.module);
      relatedOptions =
        attrs.relatedOptions or [
          (optionPath ++ [ "enable" ])
          optionPath
        ];
      platformsStr = lib.concatStringsSep "\n" (map (p: "  - ${p}") (lib.sort (a: b: a < b) platforms));
    in
    {
      assertion = lib.elem pkgs.stdenv.hostPlatform.system platforms;
      inherit relatedOptions;
      message = ''
        The module ${attrs.module} does not support your platform. It only supports

        ${platformsStr}'';
    };
}
