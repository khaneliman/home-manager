{ lib }:

{
  /*
    Builds a platform assertion for the given module.

    The first argument is either the module's option path as a string, for
    example "programs.foo", or an attribute set with:

    - `module`: the name shown in the assertion message;
    - `relatedOptions`: option paths whose definition locations are shown
      with the failure. Defaults to the module's `enable` option so the
      message points at the user file enabling the module.
  */
  assertPlatform =
    moduleOrAttrs: pkgs: platforms:
    let
      attrs = if lib.isAttrs moduleOrAttrs then moduleOrAttrs else { module = moduleOrAttrs; };

      optionPath = lib.splitString "." attrs.module;
      relatedOptions = attrs.relatedOptions or [ (optionPath ++ [ "enable" ]) ];

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
