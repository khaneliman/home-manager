{ lib }:

let
  filesForRelatedOptions =
    options: assertion: lib.hm.diagnostics.filesForOptions options (assertion.relatedOptions or [ ]);
in
{
  filterUnknownFiles = lib.filter (file: toString file != "<unknown-file>");

  filesForOption =
    options: path:
    let
      option = lib.attrByPath path { } options;
      declarationFiles = map toString (option.declarations or [ ]);
    in
    lib.filter (file: !(builtins.elem (toString file) declarationFiles)) (
      lib.hm.diagnostics.filterUnknownFiles (option.files or [ ])
    );

  filesForOptions =
    options: paths: lib.unique (lib.concatMap (lib.hm.diagnostics.filesForOption options) paths);

  formatFiles =
    files:
    let
      knownFiles = lib.hm.diagnostics.filterUnknownFiles files;
    in
    lib.optionalString (knownFiles != [ ]) " defined in ${lib.showFiles knownFiles}";

  withDefinitionFiles =
    {
      kind,
      message,
      files ? [ ],
      options ? null,
      option ? null,
      relatedOptions ? [ ],
    }:
    let
      optionFiles = lib.optionals (options != null && option != null) (
        lib.hm.diagnostics.filesForOption options option
      );
      relatedFiles = lib.optionals (options != null) (
        lib.hm.diagnostics.filesForOptions options relatedOptions
      );
      allFiles = lib.unique (
        lib.hm.diagnostics.filterUnknownFiles (files ++ optionFiles ++ relatedFiles)
      );
    in
    if allFiles == [ ] || lib.hasInfix "defined in " message || lib.hasInfix "Defined in " message then
      message
    else
      ''
        ${lib.removeSuffix "\n" message}

        ${kind} defined in ${lib.showFiles allFiles}.'';

  warningForOption =
    options: option: message:
    lib.hm.diagnostics.withDefinitionFiles {
      kind = "Warning";
      inherit message options option;
    };

  warningForOptions =
    options: relatedOptions: message:
    lib.hm.diagnostics.withDefinitionFiles {
      kind = "Warning";
      inherit message options relatedOptions;
    };

  collectFailedAssertions =
    options: assertions:
    let
      failed = lib.filter (x: !x.assertion) assertions;
    in
    map (
      assertion:
      lib.hm.diagnostics.withDefinitionFiles {
        kind = "Assertion";
        inherit (assertion) message;
        files = filesForRelatedOptions options assertion;
      }
    ) failed;
}
