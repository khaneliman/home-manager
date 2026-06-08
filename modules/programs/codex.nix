{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.programs.codex;

  tomlFormat = pkgs.formats.toml { };
  yamlFormat = pkgs.formats.yaml { };

  # A null package has no detectable version, so assume the latest Codex and
  # enable version-gated behavior by default.
  atLeast = version: cfg.package == null || lib.versionAtLeast (lib.getVersion cfg.package) version;
  isTomlConfig = atLeast "0.2.0";
  migrateLegacyProfiles = atLeast "0.134.0";
  settingsFormat = if isTomlConfig then tomlFormat else yamlFormat;
in
{
  meta.maintainers = [
    lib.maintainers.delafthi
  ];

  imports = [
    (lib.mkRenamedOptionModule
      [ "programs" "codex" "custom-instructions" ]
      [ "programs" "codex" "context" ]
    )
  ];

  options.programs.codex = {
    enable = lib.mkEnableOption "Lightweight coding agent that runs in your terminal";

    package = lib.mkPackageOption pkgs "codex" { nullable = true; };

    enableMcpIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to integrate the MCP server config from
        {option}`programs.mcp.servers` into
        {option}`programs.codex.settings.mcp_servers`.

        Note: Settings defined in {option}`programs.mcp.servers` are merged
        with {option}`programs.codex.settings.mcp_servers`, with settings-based
        values taking precedence.
      '';
    };

    settings = lib.mkOption {
      # NOTE: `yaml` type supports null, using `nullOr` for backwards compatibility period
      type = lib.types.nullOr tomlFormat.type;
      description = ''
        Configuration written to {file}`CODEX_HOME/config.toml` (0.2.0+)
        or {file}`~/.codex/config.yaml` (<0.2.0). Per default {env}`CODEX_HOME`
        defaults to ~/.codex.
        See <https://github.com/openai/codex/blob/main/codex-rs/config.md> for supported values.
      '';
      default = { };
      defaultText = lib.literalExpression "{ }";
      example = lib.literalExpression ''
        {
          model = "gemma3:latest";
          model_provider = "ollama";
          model_providers = {
            ollama = {
              name = "Ollama";
              baseURL = "http://localhost:11434/v1";
              envKey = "OLLAMA_API_KEY";
            };
          };
          mcp_servers = {
            context7 = {
              command = "npx";
              args = [
                "-y"
                "@upstash/context7-mcp"
              ];
            };
          };
        }
      '';
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf tomlFormat.type;
      default = { };
      description = ''
        Named Codex configuration profiles written to
        {file}`CODEX_HOME/<name>.config.toml`.

        These profiles are selected with {command}`codex --profile <name>`.
        Codex 0.134.0 and later no longer reads profile settings from
        {option}`programs.codex.settings.profiles`, and the top-level
        {option}`programs.codex.settings.profile` selector is no longer
        supported.
      '';
      example = lib.literalExpression ''
        {
          deep-review = {
            model = "gpt-5.5";
            model_reasoning_effort = "xhigh";
            approval_policy = "on-request";
            sandbox_mode = "workspace-write";
          };
        }
      '';
    };

    context = lib.mkOption {
      type = lib.types.either lib.types.lines lib.types.path;
      description = ''
        Global context for Codex.

        The value is either:
        - Inline content as a string
        - A path to a file containing the content

        The configured content is written to
        {file}`CODEX_HOME/AGENTS.md`.
      '';
      default = "";
      example = lib.literalExpression ''
        '''
          - Always respond with emojis
          - Only use git commands when explicitly requested
        '''
      '';
    };

    skills = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path)) lib.types.path;
      default = { };
      description = ''
        Custom skills for Codex.

        This option can be either:
        - An attribute set defining skills
        - A path to a directory containing skill folders

        If an attribute set is used, the attribute name becomes the
        skill directory name, and the value is either:
        - Inline content as a string (creates a generated skill directory at {file}`<skills-dir>/<name>/`)
        - A path to a file (creates a generated skill directory at {file}`<skills-dir>/<name>/`)
        - A path to a directory (symlinks {file}`<skills-dir>/<name>/` to that directory)

        If a path is used, it is expected to contain one folder per
        skill name, each containing a {file}`SKILL.md`. Each top-level
        skill entry is symlinked into {file}`<skills-dir>/`, leaving
        {file}`<skills-dir>/` itself as a normal directory so unmanaged
        skills can coexist.

        Home Manager manages skills under {file}`CODEX_HOME/skills`
        (typically {file}`~/.codex/skills`, or
        {file}`~/.config/codex/skills` when
        {option}`home.preferXdgDirectories` is enabled).
      '';
      example = lib.literalExpression ''
        {
          pdf-processing = '''
            ---
            name: pdf-processing
            description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
            ---

            # PDF Processing

            ## Quick start

            Use pdfplumber to extract text from PDFs:

            ```python
            import pdfplumber

            with pdfplumber.open("document.pdf") as pdf:
                text = pdf.pages[0].extract_text()
            ```
          ''';
          data-analysis = ./skills/data-analysis;
        }
      '';
    };

    rules = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path);
      default = { };
      description = ''
        Codex rules files to manage under {file}`CODEX_HOME/rules/`.

        The attribute name becomes the filename, with a {file}`.rules`
        extension added automatically. The value is either:
        - Inline content as a string
        - A path to an existing rules file

        This is useful for declaratively managing persistent
        `prefix_rule()` definitions, including the default
        {file}`default.rules` allow-list Codex writes when you accept
        recurring approvals interactively.
      '';
      example = lib.literalExpression ''
        {
          default = "prefix_rule(pattern = [\"nix\", \"build\"], decision = \"allow\")\n";
          github = ./codex/github.rules;
        }
      '';
    };
  };

  config =
    let
      useXdgDirectories = config.home.preferXdgDirectories && isTomlConfig;
      xdgConfigHome = lib.removePrefix config.home.homeDirectory config.xdg.configHome;
      configDir = if useXdgDirectories then "${xdgConfigHome}/codex" else ".codex";
      configFileName = if isTomlConfig then "config.toml" else "config.yaml";
      skillsDir = "${configDir}/skills";

      # TODO: Remove this workaround once Codex supports symlinked SKILL.md
      # files again. Upstream only supports symlinking the containing skill
      # directory today: https://github.com/openai/codex/issues/10470
      mkSkillDir =
        content:
        pkgs.writeTextDir "SKILL.md" (
          if lib.hm.strings.isPathLike content then builtins.readFile content else content
        );
      skillSources =
        if builtins.isAttrs cfg.skills then
          cfg.skills
        else if lib.hm.strings.isPathLike cfg.skills && lib.pathIsDirectory cfg.skills then
          lib.mapAttrs (name: _type: cfg.skills + "/${name}") (builtins.readDir cfg.skills)
        else
          { };
      mkSkillEntry =
        name: content:
        if lib.hm.strings.isPathLike content && lib.pathIsDirectory content then
          lib.nameValuePair "${skillsDir}/${name}" {
            source = content;
          }
        else
          lib.nameValuePair "${skillsDir}/${name}" {
            source = mkSkillDir content;
          };
      mkRuleEntry =
        name: content:
        lib.nameValuePair "${configDir}/rules/${name}.rules" (
          if lib.hm.strings.isPathLike content then { source = content; } else { text = content; }
        );
      mkProfileEntry =
        name: settings:
        lib.nameValuePair "${configDir}/${name}.config.toml" {
          source = tomlFormat.generate "codex-${name}-config" settings;
        };

      transformedMcpServers = lib.optionalAttrs (cfg.enableMcpIntegration && config.programs.mcp.enable) (
        lib.mapAttrs (
          _name: server:
          # NOTE: Convert shared programs.mcp fields to Codex config keys:
          # - removeAttrs drops keys that Codex does not use directly
          # - "disabled" becomes inverse "enabled"
          # - "headers" is renamed to "http_headers"
          # See: https://developers.openai.com/codex/mcp#other-configuration-options
          (lib.removeAttrs server [
            "disabled"
            "headers"
          ])
          // (lib.optionalAttrs (server ? headers && !(server ? http_headers)) {
            http_headers = server.headers;
          })
          // {
            enabled = !(server.disabled or false);
          }
        ) config.programs.mcp.servers
      );

      settingMcpServers = lib.attrByPath [ "mcp_servers" ] { } cfg.settings;
      mergedMcpServers = transformedMcpServers // settingMcpServers;
      # TODO: remove this migration block in a future stateVersion once the
      # Codex 0.134 profile transition window has passed.
      hasLegacyProfileSettings =
        migrateLegacyProfiles && ((cfg.settings ? profile) || (cfg.settings ? profiles));
      legacyProfiles = lib.optionalAttrs (
        hasLegacyProfileSettings && builtins.isAttrs (cfg.settings.profiles or null)
      ) cfg.settings.profiles;
      mergedProfiles = legacyProfiles // cfg.profiles;
      baseSettings =
        if hasLegacyProfileSettings then
          lib.removeAttrs cfg.settings [
            "profile"
            "profiles"
          ]
        else
          cfg.settings;
      mergedSettings =
        baseSettings // lib.optionalAttrs (mergedMcpServers != { }) { mcp_servers = mergedMcpServers; };
    in
    mkIf cfg.enable {
      warnings = lib.optional hasLegacyProfileSettings ''
        `programs.codex.settings.profile` and `programs.codex.settings.profiles`
        are no longer supported by Codex 0.134.0 and later. Home Manager
        now writes entries from `programs.codex.settings.profiles` to
        `CODEX_HOME/<name>.config.toml`. Move them to
        `programs.codex.profiles` and remove `programs.codex.settings.profile`.
      '';

      assertions = [
        {
          assertion = !lib.hm.strings.isPathLike cfg.skills || lib.pathIsDirectory cfg.skills;
          message = "`programs.codex.skills` must be a directory when set to a path";
        }
        {
          assertion = lib.all (content: !(lib.hm.strings.isPathLike content && lib.pathIsDirectory content)) (
            lib.attrValues cfg.rules
          );
          message = "`programs.codex.rules` attribute values must be files when set to paths";
        }
      ];

      home = {
        packages = mkIf (cfg.package != null) [ cfg.package ];

        file = {
          "${configDir}/${configFileName}" = lib.mkIf (mergedSettings != { }) {
            source = settingsFormat.generate "codex-config" mergedSettings;
          };
          "${configDir}/AGENTS.md" =
            if lib.isPath cfg.context then
              { source = cfg.context; }
            else
              lib.mkIf (cfg.context != "") {
                text = cfg.context;
              };
        }
        // lib.mapAttrs' mkProfileEntry mergedProfiles
        // lib.mapAttrs' mkSkillEntry skillSources
        // lib.mapAttrs' mkRuleEntry cfg.rules;

        sessionVariables = mkIf useXdgDirectories {
          CODEX_HOME = "${config.xdg.configHome}/codex";
        };
      };
    };
}
