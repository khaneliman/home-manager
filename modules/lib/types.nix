{
  lib,
  gvariant ? import ./gvariant.nix { inherit lib; },
}:

let
  inherit (lib)
    all
    concatMap
    foldl'
    getFiles
    getValues
    head
    isFunction
    literalExpression
    mergeAttrs
    mergeDefaultOption
    mergeOneOption
    mkOption
    mkOptionType
    showFiles
    showOption
    types
    optionalString
    ;

  typesDag = import ./types-dag.nix { inherit lib; };

  # Needed since the type is called gvariant and its merge attribute
  # must refer back to the type.
  gvar = gvariant;

in
rec {

  inherit (typesDag) dagOf;

  selectorFunction = mkOptionType {
    name = "selectorFunction";
    description =
      "Function that takes an attribute set and returns a list"
      + " containing a selection of the values of the input set";
    check = isFunction;
    merge =
      _loc: defs: as:
      concatMap (select: select as) (getValues defs);
  };

  overlayFunction = mkOptionType {
    name = "overlayFunction";
    description =
      "An overlay function, takes self and super and returns"
      + " an attribute set overriding the desired attributes.";
    check = isFunction;
    merge =
      _loc: defs: self: super:
      foldl' (res: def: mergeAttrs res (def.value self super)) { } defs;
  };

  fontType = types.submodule {
    options = {
      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        example = literalExpression "pkgs.dejavu_fonts";
        description = ''
          Package providing the font. This package will be installed
          to your profile. If `null` then the font
          is assumed to already be available in your profile.
        '';
      };

      name = mkOption {
        type = types.str;
        example = "DejaVu Sans";
        description = ''
          The family name of the font within the package.
        '';
      };

      size = mkOption {
        type = types.nullOr types.number;
        default = null;
        example = "8";
        description = ''
          The size of the font.
        '';
      };
    };
  };

  gvariant = mkOptionType rec {
    name = "gvariant";
    description = "GVariant value";
    check = v: gvar.mkValue v != null;
    merge =
      loc: defs:
      let
        vdefs = map (
          d:
          d
          // {
            value = if gvar.isGVariant d.value then d.value else gvar.mkValue d.value;
          }
        ) defs;
        vals = map (d: d.value) vdefs;
        defTypes = map (x: x.type) vals;
        sameOrNull = x: y: if x == y then y else null;
        # A bit naive to just check the first entry…
        sharedDefType = foldl' sameOrNull (head defTypes) defTypes;
        allChecked = all (x: check x) vals;
      in
      if sharedDefType == null then
        throw (
          "Cannot merge definitions of `${showOption loc}' with"
          + " mismatched GVariant types given in"
          + " ${showFiles (getFiles defs)}."
        )
      else if gvar.isArray sharedDefType && allChecked then
        gvar.mkValue ((types.listOf gvariant).merge loc (map (d: d // { value = d.value.value; }) vdefs))
        // {
          type = sharedDefType;
        }
      else if gvar.isTuple sharedDefType && allChecked then
        mergeOneOption loc defs
      else if gvar.isMaybe sharedDefType && allChecked then
        mergeOneOption loc defs
      else if gvar.isDictionaryEntry sharedDefType && allChecked then
        mergeOneOption loc defs
      else if gvar.type.variant == sharedDefType && allChecked then
        mergeOneOption loc defs
      else if gvar.type.string == sharedDefType && allChecked then
        types.str.merge loc defs
      else if gvar.type.double == sharedDefType && allChecked then
        types.float.merge loc defs
      else
        mergeDefaultOption loc defs;
  };

  nushellValue =
    let
      valueType = types.nullOr (
        types.oneOf [
          (lib.mkOptionType {
            name = "nushell";
            description = "Nushell inline value";
            descriptionClass = "name";
            check = lib.isType "nushell-inline";
          })
          types.bool
          types.int
          types.float
          types.str
          types.path
          (
            types.attrsOf valueType
            // {
              description = "attribute set of Nushell values";
              descriptionClass = "name";
            }
          )
          (
            types.listOf valueType
            // {
              description = "list of Nushell values";
              descriptionClass = "name";
            }
          )
        ]
      );
    in
    valueType;

  sourceFile =
    targetDir: fileName:
    let
      targetFile = "${targetDir}/${fileName}";
    in
    types.submodule (
      { config, ... }:
      {
        options = {
          target = mkOption {
            type = types.singleLineStr;
            internal = true;
            readOnly = true;
          };
          source = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = ''
              The path to be linked to `${targetDir}` if {option}`source` is a directory,
              or to `${targetFile}` if it is a file.
            '';
          };
          text = mkOption {
            type = types.lines;
            default = "";
            description = ''
              Text to be included in `${targetFile}`.
            '';
          };
          recursive = lib.mkEnableOption ''
            Whether to recursively link files from {option}`source` (if it is a directory) in `${targetDir}`.
          '';
        };
        config = {
          target =
            if config.source != null && lib.pathIsDirectory config.source then targetDir else targetFile;
        };
      }
    );

  sourceFileOrLines =
    targetDir: fileName:
    let
      fileType = sourceFile targetDir fileName;
      union = types.either types.lines fileType;
    in
    union
    // {
      merge =
        loc: defs:
        fileType.merge loc (
          map (
            def:
            if types.lines.check def.value then
              {
                inherit (def) file;
                value = {
                  text = def.value;
                  source = null;
                  recursive = false;
                };
              }
            else
              def
          ) defs
        );
    };

  # fileSpec :: optionType
  #
  # Core file specification type providing the foundation for all filesystem
  # configuration in Home Manager. This type defines the essential options from
  # Home Manager's file-type.nix with additional convenience features.
  #
  # This type combines the standard Home Manager file options (text, source,
  # executable, recursive) with enhanced features for script generation and
  # template processing.
  #
  # Parameters
  #
  # This is a submodule type with the following options:
  #
  # `text`: Optional inline text content as lines
  # `source`: Optional path to source file or directory
  # `executable`: Optional boolean for executable permission (null uses source mode or false)
  # `recursive`: Boolean flag for recursive directory handling (default: false)
  # `scriptType`: Optional script type for automatic shebang generation
  # `template`: Optional template configuration for header/footer wrapping
  #
  # Return value
  #
  # An attribute set conforming to the file specification schema, suitable
  # for conversion to Home Manager's home.file format via fileContentToHomeFile.
  fileSpec = types.submodule (
    { config, ... }:
    {
      _file = "hm-file-spec";
      options = {
        text = mkOption {
          type = types.nullOr types.lines;
          default = null;
          description = "Inline text content for the file.";
        };
        source = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "The path to the source file or directory.";
        };
        executable = mkOption {
          type = types.nullOr types.bool;
          default = null;
          description = "Whether the resulting file should be executable.";
        };
        recursive = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to recursively link/copy the directory from `source`.";
        };

        # Enhanced options for script generation
        scriptType = mkOption {
          type = types.nullOr (
            types.enum [
              "bash"
              "sh"
              "lua"
              "python"
              "perl"
              "ruby"
            ]
          );
          default = null;
          description = "Script type - automatically adds appropriate shebang and sets executable = true.";
        };
        template = mkOption {
          type = types.nullOr (
            types.submodule {
              options = {
                header = mkOption {
                  type = types.nullOr types.lines;
                  default = null;
                  description = "Header comment to add at the top of generated files.";
                };
                footer = mkOption {
                  type = types.nullOr types.lines;
                  default = null;
                  description = "Footer comment to add at the end of generated files.";
                };
              };
            }
          );
          default = null;
          description = "Template options for wrapping generated content.";
        };
      };
      config =
        let
          # Script type to shebang mapping
          scriptShebangs = {
            bash = "#!/usr/bin/env bash";
            sh = "#!/bin/sh";
            lua = "#!/usr/bin/env lua";
            python = "#!/usr/bin/env python3";
            perl = "#!/usr/bin/env perl";
            ruby = "#!/usr/bin/env ruby";
          };

          scriptCommentStyles = {
            bash = "#";
            sh = "#";
            python = "#";
            lua = "--";
            perl = "#";
            ruby = "#";
          };
        in
        {
          _module.args.check =
            cfg:
            let
              hasSource = cfg.source != null;
              hasText = cfg.text != null;
            in
            # Assert that `source` and `text` are not used at the same time.
            if hasSource && hasText then
              throw ''
                The `source` and `text` options are mutually exclusive. Please choose one.
                Source: ${toString cfg.source}
              ''
            else
              true;

          template = lib.mkIf (config.scriptType != null) (
            lib.mkDefault {
              header =
                let
                  commentChar = scriptCommentStyles.${config.scriptType};
                in
                "${commentChar} Generated by home-manager";
              footer = null;
            }
          );

          # This text-generation logic now automatically picks up our default header,
          # or a user-provided one if it exists. No changes needed here!
          text = lib.mkIf (config.scriptType != null || config.template != null) (
            let
              shebang = optionalString (config.scriptType != null) (scriptShebangs.${config.scriptType});
              header = optionalString (
                config.template != null && config.template.header != null
              ) config.template.header;
              body = config.text;
              footer = optionalString (
                config.template != null && config.template.footer != null
              ) config.template.footer;
              allParts = lib.filter (s: s != null && s != "") [
                shebang
                header
                body
                footer
              ];
            in
            lib.concatStringsSep "\n\n" allParts
          );

          executable = lib.mkIf (config.scriptType != null) true;
        };
    }
  );

  # fileContent :: optionType
  #
  # Flexible file content type that accepts string, path, or full file specification.
  # This is the recommended type for most filesystem configuration use cases in
  # Home Manager as it provides maximum convenience while maintaining type safety.
  #
  # The type automatically converts between different input formats:
  # - Strings become inline text content
  # - Paths become file sources (with automatic recursive detection for directories)
  # - Attribute sets are treated as full file specifications
  #
  # Parameters
  #
  #     fileContent value
  #
  # `value`: One of the following:
  #   - String: Inline text content
  #   - Path: Source file or directory path
  #   - Attribute set: Full file specification matching fileSpec schema
  #
  # Return value
  #
  # A normalized file specification attribute set. Multiple definitions cannot
  # be merged - this type enforces a single definition per option location.
  #
  # Example usage
  #
  #     # String input
  #     content = "Hello, world!";
  #
  #     # Path input
  #     content = ./my-config.conf;
  #
  #     # Full specification
  #     content = {
  #       text = "#!/usr/bin/env bash\necho hello";
  #       executable = true;
  #       scriptType = "bash";
  #     };
  fileContent =
    types.oneOf [
      types.lines
      types.path
      fileSpec
    ]
    // {
      name = "fileContent";
      description = "a string, a path, or a file specification set";

      merge =
        loc: defs:
        let
          normalize =
            value:
            if lib.isString value then
              { text = value; }
            else if lib.isPath value then
              {
                source = value;
                recursive = lib.pathIsDirectory value;
              }
            else
              value;

          normalizedDefs = map (def: def // { value = normalize def.value; }) defs;
          baseResult = fileSpec.merge loc normalizedDefs;

          # Apply script processing if scriptType is present
          processedResult = 
            if baseResult.scriptType != null && baseResult.text != null then
              let
                scriptShebangs = {
                  bash = "#!/usr/bin/env bash";
                  sh = "#!/bin/sh";
                  lua = "#!/usr/bin/env lua";
                  python = "#!/usr/bin/env python3";
                  perl = "#!/usr/bin/env perl";
                  ruby = "#!/usr/bin/env ruby";
                };
                scriptComments = {
                  bash = "#";
                  sh = "#";
                  lua = "--";
                  python = "#";
                  perl = "#";
                  ruby = "#";
                };
                shebang = scriptShebangs.${baseResult.scriptType};
                header = "${scriptComments.${baseResult.scriptType}} Generated by home-manager";
                body = baseResult.text;
                generatedText = lib.concatStringsSep "\n" [ shebang header body ];
              in
              baseResult // { 
                text = generatedText;
                executable = true;
              }
            else
              baseResult;
        in
        processedResult;
    };

  # extractFileSpecOptions :: optionType -> attrSet
  #
  # Helper function to extract the user-facing options from fileSpec without
  # internal module system options like _module.freeformType. This enables
  # reuse of the core file specification in other contexts.
  #
  # Parameters
  #
  #     extractFileSpecOptions fileSpecType
  #
  # `fileSpecType`: A submodule type (like fileSpec)
  #
  # Return value
  #
  # An attribute set containing only the user-defined options, suitable
  # for merging into other module option definitions.
  extractFileSpecOptions =
    fileSpecType:
    let
      allOptions = fileSpecType.getSubOptions [ ];
      userOptions = lib.filterAttrs (name: _: !lib.hasPrefix "_" name) allOptions;
    in
    userOptions;

  fileSpecToHomeFileAttrs =
    fileSpecValue:
    let
      # Process through fileContent to trigger script processing
      processedValue = fileContent.merge ["fileSpecToHomeFileAttrs"] [
        { file = "fileSpecToHomeFileAttrs"; value = fileSpecValue; }
      ];
    in
    # Unconditionally include executable and recursive, since `false` is a valid value.
    {
      inherit (processedValue) executable recursive;
    }
    # ONLY include the `text` attribute if it's not null.
    // lib.optionalAttrs (processedValue.text != null) {
      text = processedValue.text;
    }
    # ONLY include the `source` attribute if it's not null.
    // lib.optionalAttrs (processedValue.source != null) {
      source = processedValue.source;
    };

  # attrsOfFileContentToHomeFiles :: str -> attrsOf fileContent -> attrsOf homeFileAttrs
  #
  # Converts an attribute set of fileContent values into Home Manager's home.file
  # format with proper path prefixing. This is a convenience function for bulk
  # conversion of configuration files within a specific target directory.
  #
  # Parameters
  #
  #     attrsOfFileContentToHomeFiles targetDir content
  #
  # `targetDir`: String path prefix to prepend to all file names
  # `content`: Attribute set where keys are filenames and values are fileContent
  #
  # Return value
  #
  # An attribute set suitable for merging into home.file, where:
  # - Keys are full paths: "${targetDir}/${name}"
  # - Values are converted homeFileAttrs from fileContentToHomeFile
  #
  # Example usage
  #
  #     # Input
  #     attrsOfFileContentToHomeFiles ".config/app" {
  #       "config.ini" = "key=value";
  #       "script.sh" = { text = "echo hello"; executable = true; };
  #     }
  #
  #     # Output
  #     {
  #       ".config/app/config.ini".text = "key=value";
  #       ".config/app/script.sh" = { text = "echo hello"; executable = true; };
  #     }
  mkHomeFiles =
    targetDir: contentMap:
    lib.mapAttrs' (
      fileName: fileContentValue:
      lib.nameValuePair "${targetDir}/${fileName}" (fileSpecToHomeFileAttrs fileContentValue)
    ) contentMap;
}
