{
  homeDirectory,
  lib,
  pkgs,
}:

let
  inherit (lib)
    hasPrefix
    hm
    literalExpression
    mkDefault
    mkIf
    mkOption
    removePrefix
    types
    ;

  # Import the core file types from types.nix
  hmTypes = import ./types.nix { inherit lib; };
in
{
  # Constructs a type suitable for a `home.file` like option. The
  # target path may be either absolute or relative, in which case it
  # is relative the `basePath` argument (which itself must be an
  # absolute path).
  #
  # Arguments:
  #   - opt            the name of the option, for self-references
  #   - basePathDesc   docbook compatible description of the base path
  #   - basePath       the file base path
  fileType =
    opt: basePathDesc: basePath:
    types.attrsOf (
      types.submodule (
        { name, config, ... }:
        {
          options =
            # Extract core file options from fileSpec, filtering out internal module options
            hmTypes.extractFileSpecOptions hmTypes.fileSpec // {
              enable = mkOption {
                type = types.bool;
                default = true;
                description = ''
                  Whether this file should be generated. This option allows specific
                  files to be disabled.
                '';
              };
              target = mkOption {
                type = types.str;
                apply =
                  p:
                  let
                    absPath = if hasPrefix "/" p then p else "${basePath}/${p}";
                  in
                  removePrefix (homeDirectory + "/") absPath;
                defaultText = literalExpression "name";
                description = ''
                  Path to target file relative to ${basePathDesc}.
                '';
              };

              # Override source to be non-nullable since it's required in Home Manager
              source = mkOption {
                type = types.path;
                description = ''
                  Path of the source file or directory. If
                  [](#opt-${opt}._name_.text)
                  is non-null then this option will automatically point to a file
                  containing that text.
                '';
              };

              ignorelinks = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  When `recursive` is enabled, adds `-ignorelinks` flag to lndir

                  It causes lndir to not treat symbolic links in the source directory specially.
                  The link created in the target directory will point back to the corresponding
                  (symbolic link) file in the source directory. If the link is to a directory
                '';
              };

              onChange = mkOption {
                type = types.lines;
                default = "";
                description = ''
                  Shell commands to run when file has changed between
                generations. The script will be run
                *after* the new files have been linked
                into place.

                Note, this code is always run when `recursive` is
                enabled.
                '';
              };

              force = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  Whether the target path should be unconditionally replaced
                  by the managed file source. Warning, this will silently
                  delete the target regardless of whether it is a file or
                  link.
                '';
              };
            };

          config = {
            target = mkDefault name;
            source = mkIf (config.text != null) (
              mkDefault (
                pkgs.writeTextFile {
                  inherit (config) text;
                  executable = config.executable == true; # can be null
                  name = hm.strings.storeFileName name;
                }
              )
            );
          };
        }
      )
    );
}
