{ lib }:

let
  valuesWithFiles =
    option:
    lib.concatMap (
      definition:
      map (value: {
        inherit value;
        files = lib.optionals (toString definition.file != "<unknown-file>") [ definition.file ];
      }) definition.value
    ) option.definitionsWithLocations;

  filesForValue =
    value: definitions:
    lib.unique (
      lib.concatMap (definition: lib.optionals (definition.value == value) definition.files) definitions
    );

  filesForOptionPath =
    options: path:
    let
      option = lib.attrByPath path { } options;
    in
    lib.filter (file: toString file != "<unknown-file>") (option.files or [ ]);

  filesForRelatedOptions =
    options: assertion:
    lib.unique (lib.concatMap (filesForOptionPath options) (assertion.relatedOptions or [ ]));

  addDefinitionFiles =
    kind: message: files:
    if files == [ ] || lib.hasInfix "defined in " message || lib.hasInfix "Defined in " message then
      message
    else
      ''
        ${lib.removeSuffix "\n" message}

        ${kind} defined in ${lib.showFiles files}.'';
in
{
  formatWarnings =
    option: warnings:
    let
      definitions = valuesWithFiles option;
    in
    map (warning: addDefinitionFiles "Warning" warning (filesForValue warning definitions)) warnings;

  collectFailedAssertions =
    options: assertions:
    let
      definitions = valuesWithFiles options.assertions;
      failed = lib.filter (x: !x.assertion) assertions;
    in
    map (
      assertion:
      let
        relatedFiles = filesForRelatedOptions options assertion;
        files = if relatedFiles != [ ] then relatedFiles else filesForValue assertion definitions;
      in
      addDefinitionFiles "Assertion" assertion.message files
    ) failed;
}
