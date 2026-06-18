{ lib }:

let
  # Find all options declared in a specific file.
  findOptionsDeclaredIn =
    file: options:
    let
      recurse =
        opts:
        if opts._type or "" == "option" then
          if lib.elem (toString file) (map toString (opts.declarations or [ ])) then [ opts ] else [ ]
        else
          lib.concatMap recurse (
            map (name: opts.${name}) (
              lib.filter (name: name != "_module" && name != "_type") (lib.attrNames opts)
            )
          );
    in
    recurse options;

  # Get the user-defined files for a list of options (filtering out the declaration files).
  userFilesForOptions =
    opts:
    lib.unique (
      lib.concatMap (
        opt:
        let
          declarationFiles = map toString (opt.declarations or [ ]);
        in
        lib.filter (f: !lib.elem (toString f) declarationFiles) (opt.files or [ ])
      ) opts
    );

  # Find user files for any options declared in the same file as the warning/assertion.
  filesForModuleOfFile =
    options: file:
    let
      declaredOpts = findOptionsDeclaredIn file options;
      userFiles = userFilesForOptions declaredOpts;
    in
    if userFiles != [ ] then userFiles else [ file ];

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

  # Auto-resolve files for a warning message.
  warningFiles =
    options: warning:
    let
      warningsInfo = options.warnings or { };
      definitions = warningsInfo.definitionsWithLocations or [ ];
      matchingDefs = lib.filter (
        def: lib.any (val: toString val == toString warning) def.value
      ) definitions;
      defFiles = map (def: def.file) matchingDefs;
      knownDefFiles = lib.hm.diagnostics.filterUnknownFiles defFiles;
    in
    lib.unique (lib.concatMap (filesForModuleOfFile options) knownDefFiles);

  # Automatic warning wrapper called at the root evaluation level.
  formatWarnings =
    options: warnings:
    map (
      warning:
      let
        files = lib.hm.diagnostics.warningFiles options warning;
      in
      lib.hm.diagnostics.withDefinitionFiles {
        kind = "Warning";
        message = warning;
        inherit files;
      }
    ) warnings;

  collectFailedAssertions =
    options: assertions:
    let
      failed = lib.filter (x: !x.assertion) assertions;

      assertionsInfo = options.assertions or { };
      definitions = assertionsInfo.definitionsWithLocations or [ ];

      filesForAssertion =
        assertion:
        let
          related = filesForRelatedOptions options assertion;
        in
        if related != [ ] then
          related
        else
          let
            matchingDefs = lib.filter (
              def: lib.any (val: val.message or "" == assertion.message) def.value
            ) definitions;
            defFiles = map (def: def.file) matchingDefs;
            knownDefFiles = lib.hm.diagnostics.filterUnknownFiles defFiles;
          in
          lib.unique (lib.concatMap (filesForModuleOfFile options) knownDefFiles);
    in
    map (
      assertion:
      lib.hm.diagnostics.withDefinitionFiles {
        kind = "Assertion";
        inherit (assertion) message;
        files = filesForAssertion assertion;
      }
    ) failed;
}
