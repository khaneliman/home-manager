{ lib }:
{
  # Removes placeholder files that the module system uses for definitions
  # without a known source location.
  filterUnknownFiles = lib.filter (file: toString file != "<unknown-file>");

  # Accepts an option path as either a list of segments or a dot-separated
  # string and returns the list form.
  normalizeOptionPath = path: if lib.isString path then lib.splitString "." path else path;

  /*
    Files in which the user defined the option at `path`.

    Definitions coming from the option's own declaring modules are excluded
    so that module-provided defaults (`mkDefault` and friends) do not make
    the diagnostics point back at Home Manager itself.
  */
  filesForOption =
    options: path:
    let
      option = lib.attrByPath (lib.hm.diagnostics.normalizeOptionPath path) { } options;
      declarationFiles = map toString (option.declarations or [ ]);
    in
    lib.filter (file: !(lib.elem (toString file) declarationFiles)) (
      lib.hm.diagnostics.filterUnknownFiles (option.files or [ ])
    );

  filesForOptions =
    options: paths: lib.unique (lib.concatMap (lib.hm.diagnostics.filesForOption options) paths);

  # Appends the given definition locations to a diagnostic message so the
  # user knows which of their configuration files to update.
  appendDefinitionLocations =
    files: message:
    if files == [ ] then
      message
    else
      ''
        ${lib.removeSuffix "\n" message}

        Caused by definitions in ${lib.showFiles files}.'';

  # Renders one entry of `config.warnings` to a string, resolving any
  # related options to the files in which the user defined them.
  formatWarning =
    options: warning:
    if lib.isString warning then
      warning
    else
      lib.hm.diagnostics.appendDefinitionLocations (lib.hm.diagnostics.filesForOptions options (
        warning.relatedOptions or [ ]
      )) warning.message;

  formatWarnings = options: warnings: map (lib.hm.diagnostics.formatWarning options) warnings;

  # Returns the messages of all failed assertions, each annotated with the
  # definition locations of its related options when provided.
  collectFailedAssertions =
    options: assertions:
    map (
      assertion:
      lib.hm.diagnostics.appendDefinitionLocations (lib.hm.diagnostics.filesForOptions options (
        assertion.relatedOptions or [ ]
      )) assertion.message
    ) (lib.filter (x: !x.assertion) assertions);
}
