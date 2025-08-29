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
  fileSpec = types.submodule {
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
  };

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
  fileContent = mkOptionType {
    name = "fileContent";
    description = "string, path, or file specification";
    check = value: types.lines.check value || types.path.check value || fileSpec.check value;
    merge =
      loc: defs:
      let
        convertDef =
          def:
          if lib.isString def.value then
            { text = def.value; }
          else if lib.isPath def.value then
            let
              isDir = lib.pathIsDirectory def.value;
            in
            {
              source = def.value;
            }
            // lib.optionalAttrs isDir { recursive = true; }
          else
            # For attribute sets, only include non-null values
            lib.optionalAttrs (def.value ? text && def.value.text != null) {
              inherit (def.value) text;
            }
            // lib.optionalAttrs (def.value ? source && def.value.source != null) {
              inherit (def.value) source;
            }
            // lib.optionalAttrs (def.value ? executable) {
              inherit (def.value) executable;
            }
            // lib.optionalAttrs (def.value ? recursive) {
              inherit (def.value) recursive;
            }
            // lib.optionalAttrs (def.value ? scriptType && def.value.scriptType != null) {
              inherit (def.value) scriptType;
            }
            // lib.optionalAttrs (def.value ? template && def.value.template != null) {
              inherit (def.value) template;
            };
      in
      if lib.length defs == 1 then
        convertDef (lib.head defs)
      else
        throw "fileContent cannot merge multiple definitions at ${lib.showOption loc}";
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

  # Script type to shebang mapping
  scriptShebangs = {
    bash = "#!/usr/bin/env bash";
    sh = "#!/bin/sh";
    lua = "#!/usr/bin/env lua";
    python = "#!/usr/bin/env python3";
    perl = "#!/usr/bin/env perl";
    ruby = "#!/usr/bin/env ruby";
  };

  # fileContentToHomeFile :: fileContent -> homeFileAttrs
  #
  # Converts a fileContent value into Home Manager's home.file attribute format.
  # This function handles the transformation from the flexible fileContent type
  # to the specific attribute structure expected by Home Manager's file management.
  #
  # The function processes script types by adding appropriate shebangs, handles
  # template wrapping with headers and footers, and manages file permissions
  # and directory recursion settings.
  #
  # Parameters
  #
  #     fileContentToHomeFile content
  #
  # `content`: A fileContent value (string, path, or file specification)
  #
  # Return value
  #
  # An attribute set suitable for use in home.file, containing:
  # - `text`: Generated or passed-through text content (if applicable)
  # - `source`: Source path (if applicable)
  # - `executable`: Boolean permission flag (if needed)
  # - `recursive`: Boolean directory flag (if needed)
  #
  # The function automatically:
  # - Adds shebangs for recognized script types
  # - Wraps content with template headers/footers
  # - Sets executable permissions for scripts
  # - Enables recursive mode for directory paths
  fileContentToHomeFile =
    content:
    if lib.isString content then
      { text = content; }
    else if lib.isPath content then
      let
        isDir = lib.pathIsDirectory content;
      in
      { source = content; } // lib.optionalAttrs isDir { recursive = true; }
    else
      let
        hasScriptType = content ? scriptType && content.scriptType != null;
        hasTemplate = content ? template && content.template != null;
        hasText = content ? text && content.text != null;

        shebang = lib.optionalString hasScriptType scriptShebangs.${content.scriptType};
        header = lib.optionalString (
          hasTemplate && content.template ? header && content.template.header != null
        ) content.template.header;

        footer = lib.optionalString (
          hasTemplate && content.template ? footer && content.template.footer != null
        ) content.template.footer;

        generatedText =
          if hasText && (hasScriptType || hasTemplate) then
            let
              parts = lib.filter (x: x != "") [
                shebang
                header
                content.text
                footer
              ];
              joined = lib.concatStringsSep "\n" parts;
            in
            # Ensure trailing newline if we generated content
            if joined != "" && !lib.hasSuffix "\n" joined then joined + "\n" else joined
          else if hasText then
            content.text
          else
            null;

        baseAttrs =
          lib.optionalAttrs (content ? source && content.source != null) {
            inherit (content) source;
          }
          // lib.optionalAttrs (content ? recursive) {
            inherit (content) recursive;
          }
          // lib.optionalAttrs (content ? executable || hasScriptType) {
            executable = content.executable or hasScriptType;
          };

      in
      if generatedText != null then baseAttrs // { text = generatedText; } else baseAttrs;

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
  attrsOfFileContentToHomeFiles =
    targetDir: content:
    lib.mapAttrs' (
      name: value: lib.nameValuePair "${targetDir}/${name}" (fileContentToHomeFile value)
    ) content;
}
