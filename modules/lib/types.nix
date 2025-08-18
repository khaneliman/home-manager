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

  /**
    * A generic type representing the content of a file.
    *
    * This type can be satisfied in two ways:
    * 1. A raw string (`types.lines`) for inline text content.
    * 2. An attribute set with the following options:
    * - `source`: The path to a source file.
    * - `text`: Inline text content (an alternative to `source`).
    * - `executable`: (Optional) A boolean to indicate if the file should be executable.
  */
  fileContent =
    let
      fileSpecType = types.submodule {
        options = {
          source = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "The path to the source file.";
          };
          text = mkOption {
            type = types.nullOr types.lines;
            default = null;
            description = "Inline text content for the file.";
          };
          executable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether the resulting file should be executable.";
          };
        };
      };

    in
    types.either types.lines fileSpecType
    // {
      name = "file-content";

      merge =
        loc: defs:
        fileSpecType.merge loc (
          map (
            def:
            if types.lines.check def.value then
              {
                inherit (def) file;
                value = {
                  text = def.value;
                  source = null;
                  executable = false;
                };
              }
            else if
              def.value ? source && def.value ? text && def.value.source != null && def.value.text != null
            then
              throw "A file cannot have both `source` and `text` defined at the same time."
            else
              def
          ) defs
        );
    };

  /**
    A helper function to create a complete file management configuration.

    This function takes path information and a `fileContent`-compatible value
    and returns a normalized attribute set containing the derived `target` path
    and the file's content specification.

    It intelligently determines if the target should be the directory itself
    (if the source is a directory) or a file within that directory.

    @param targetDir   The base directory for the target.
    @param fileName    The name of the file within the target directory.
    @param content     A value compatible with the `fileContent` type (a string or an attrset).

    @return An attribute set: `{ target, source, text, executable, ... }`
  */
  mkManagedFile =
    targetDir: fileName: content:
    let
      normalizedContent =
        if lib.isAttrs content then
          content
        else
          {
            text = content;
            source = null;
            executable = false;
          };

      targetPath =
        if normalizedContent.source != null && lib.pathIsDirectory normalizedContent.source then
          targetDir
        else
          "${targetDir}/${fileName}";
    in
    { target = targetPath; } // normalizedContent;

  # Enhanced flexible content types
  #
  # These types provide flexible ways to specify file content in Home Manager modules,
  # supporting various patterns from simple inline text to complex directory structures.
  #
  # Usage examples:
  #
  # 1. Simple content (pathOrLines):
  #    config = "inline text";
  #    config = ./path/to/file;
  #
  # 2. Multiple files (attrsOfPathOrLines):
  #    config.file1 = "inline text";
  #    config.file2 = ./path/to/file;
  #
  # 3. Directory-aware (directoryOrFileContent):
  #    config = "inline text";
  #    config = { source = ./config-dir; recursive = true; };
  #
  # 4. Ultra-flexible (ultraFlexibleContent):
  #    config = "simple text";                    # inline
  #    config = ./path/to/file;                   # single file
  #    config = { source = ./dir; recursive = true; };  # directory
  #    config = {                                 # multiple files
  #      file1 = "content1";
  #      file2 = ./external-file;
  #      file3 = { source = ./another-dir; recursive = false; };
  #    };
  #
  # 5. RFC 42 style (settingsContent):
  #    config = "simple text";
  #    config = { settings.file1 = "content"; settings.file2 = ./file; };

  /**
    * Simple union of path or lines content.
    * Accepts either a file path or inline text content.
  */
  pathOrLines = types.either types.path types.lines;

  /**
    * Attribute set where each value can be a path or lines content.
    * Useful for configurations with multiple files where each can be
    * either inline text or a file path.
  */
  attrsOfPathOrLines = types.attrsOf pathOrLines;

  /**
    * Directory-aware content type that handles both single files and directories.
    * Accepts either lines or an attribute set with source and recursive options.
  */
  directoryOrFileContent =
    let
      dirSpecType = types.submodule {
        options = {
          source = mkOption {
            type = types.path;
            description = "Path to the source file or directory.";
          };
          recursive = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Whether to recursively copy directory contents.
              Only applies when source is a directory.
            '';
          };
        };
      };
    in
    types.either types.lines dirSpecType;

  /**
    * Ultra-flexible content type that handles all common file content patterns.
    * This type can accept:
    * - Simple string content (types.lines)
    * - A file path (types.path)
    * - Directory specification with recursive option
    * - Attribute set of mixed content types
  */
  ultraFlexibleContent =
    let
      # Individual content item - can be lines, path, or directory spec
      contentItem = types.oneOf [
        types.lines
        types.path
        (types.submodule {
          options = {
            source = mkOption {
              type = types.path;
              description = "Path to the source file or directory.";
            };
            recursive = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to recursively copy directory contents.";
            };
            text = mkOption {
              type = types.nullOr types.lines;
              default = null;
              description = "Inline text content (alternative to source).";
            };
          };
        })
      ];

      # The full flexible type
      flexType = types.oneOf [
        types.lines # Simple string
        types.path # Simple path
        (types.submodule {
          # Directory with options
          options = {
            source = mkOption {
              type = types.path;
              description = "Path to the source file or directory.";
            };
            recursive = mkOption {
              type = types.bool;
              default = false;
              description = "Whether to recursively copy directory contents.";
            };
            text = mkOption {
              type = types.nullOr types.lines;
              default = null;
              description = "Inline text content (alternative to source).";
            };
          };
        })
        (types.attrsOf contentItem) # Attribute set of content items
      ];
    in
    flexType;

  /**
    * Settings-aware flexible content type following RFC 42 patterns.
    * Similar to ultraFlexibleContent but with a 'settings' attribute for
    * attribute set configurations, making it more idiomatic for Home Manager modules.
  */
  settingsContent = types.oneOf [
    types.lines
    types.path
    (types.submodule {
      options = {
        source = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to the source file or directory.";
        };
        text = mkOption {
          type = types.nullOr types.lines;
          default = null;
          description = "Inline text content.";
        };
        recursive = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to recursively copy directory contents.";
        };
        settings = mkOption {
          type = types.nullOr (types.attrsOf pathOrLines);
          default = null;
          description = "Attribute set of file configurations.";
        };
      };
    })
  ];

  # Helper functions for flexible content types

  /**
    * Normalize flexible content to a consistent structure.
    * Converts various input formats to a normalized attribute set.
  */
  normalizeFlexibleContent =
    content:
    if lib.isString content then
      {
        text = content;
        source = null;
        recursive = false;
      }
    else if lib.isPath content then
      {
        text = null;
        source = content;
        recursive = false;
      }
    else if lib.isAttrs content then
      if content ? source || content ? text then
        # Already in expected format
        content
        // {
          text = content.text or null;
          source = content.source or null;
          recursive = content.recursive or false;
        }
      else
        # Treat as settings attribute set
        {
          text = null;
          source = null;
          recursive = false;
          settings = content;
        }
    else
      throw "Invalid flexible content format";

  /**
    * Convert flexible content to fileType-compatible format.
    * This bridges the gap between the new flexible types and existing file infrastructure.
  */
  flexibleContentToFileType =
    targetDir: fileName: content:
    let
      normalized = normalizeFlexibleContent content;
    in
    if normalized.settings != null then
      # Handle attribute set of files
      lib.mapAttrs (
        name: value:
        let
          itemNormalized = normalizeFlexibleContent value;
        in
        {
          target = "${targetDir}/${name}";
          text = itemNormalized.text;
          source = itemNormalized.source;
          recursive = itemNormalized.recursive;
        }
      ) normalized.settings
    else
      # Handle single file/directory
      {
        ${fileName} = {
          target =
            if normalized.source != null && lib.pathIsDirectory normalized.source then
              targetDir
            else
              "${targetDir}/${fileName}";
          text = normalized.text;
          source = normalized.source;
          recursive = normalized.recursive;
        };
      };

  /**
    * Enhanced sourceFileOrLines that supports the new flexible patterns.
    * Maintains backward compatibility while adding new capabilities.
  */
  enhancedSourceFileOrLines =
    targetDir: fileName:
    let
      baseType = sourceFileOrLines targetDir fileName;

      # Enhanced type that also accepts our new flexible formats
      enhancedType = types.oneOf [
        types.lines # Original: inline text
        (sourceFile targetDir fileName) # Original: file submodule
        types.path # New: simple path
        (types.attrsOf pathOrLines) # New: attribute set of files
      ];
    in
    enhancedType
    // {
      merge =
        loc: defs:
        let
          # Convert all definitions to the base sourceFile format
          convertedDefs = map (
            def:
            if types.lines.check def.value then
              # Convert lines to sourceFile format
              {
                inherit (def) file;
                value = {
                  text = def.value;
                  source = null;
                  recursive = false;
                };
              }
            else if types.path.check def.value then
              # Convert path to sourceFile format
              {
                inherit (def) file;
                value = {
                  text = null;
                  source = def.value;
                  recursive = lib.pathIsDirectory def.value;
                };
              }
            else if lib.isAttrs def.value && !(def.value ? source || def.value ? text) then
              # Convert attribute set to multiple sourceFile entries
              throw
                "Attribute set format not yet supported in enhancedSourceFileOrLines merge - use flexibleContentToFileType helper"
            else
              # Already in sourceFile format or compatible
              def
          ) defs;
        in
        baseType.merge loc convertedDefs;
    };
}
