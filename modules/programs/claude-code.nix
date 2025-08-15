{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.claude-code;

  jsonFormat = pkgs.formats.json { };
in
{
  meta.maintainers = [ lib.maintainers.khaneliman ];

  options.programs.claude-code = {
    enable = lib.mkEnableOption "Claude Code, Anthropic's official CLI";

    package = lib.mkPackageOption pkgs "claude-code" { nullable = true; };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          "theme": "dark",
          "permissions": {
            "bash": "allow",
            "edit": "allow"
          },
          "model": "claude-3-5-sonnet-20241022"
        }
      '';
      description = "JSON configuration for Claude Code settings.json";
    };

    localSettings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          "anthropic_api_key": "your-api-key-here"
        }
      '';
      description = ''
        JSON configuration for Claude Code local settings.
        These settings are kept separate and typically contain sensitive information like API keys.
      '';
    };

    agents =
      let
        agentType = lib.types.submodule {
          freeformType = jsonFormat.type;
          options = {
            description = lib.mkOption {
              type = lib.types.str;
              description = "Brief description of what this agent does";
              example = "Specialized agent for code review tasks";
            };

            prompt = lib.mkOption {
              type = lib.types.str;
              description = "The system prompt for this agent";
              example = ''
                You are a code review specialist. Focus on:
                - Code quality and best practices
                - Security vulnerabilities
                - Performance optimizations
              '';
            };

            tools = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of tools this agent has access to";
              example = [
                "Read"
                "Edit"
                "Grep"
                "Bash"
              ];
            };

            model = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Specific model to use for this agent";
              example = "claude-3-5-sonnet-20241022";
            };
          };
        };
      in
      lib.mkOption {
        type = lib.types.attrsOf agentType;
        default = { };
        description = ''
          Custom agents for Claude Code.
          Each agent will be created as a markdown file with YAML frontmatter in .claude/agents/.
        '';
        example = lib.literalExpression ''
          {
            code-reviewer = {
              description = "Specialized code review agent";
              prompt = '''
                You are a senior software engineer specializing in code reviews.
                Focus on code quality, security, and maintainability.
              ''';
              tools = [ "Read" "Edit" "Grep" ];
            };
            documentation = {
              description = "Documentation writing assistant";
              prompt = '''
                You are a technical writer who creates clear, comprehensive documentation.
                Focus on user-friendly explanations and examples.
              ''';
              tools = [ "Read" "Write" "Edit" ];
            };
          }
        '';
      };

    mcpServers =
      let
        mcpServerType = lib.types.submodule {
          freeformType = jsonFormat.type;
          options = {
            command = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Command to run for stdio transport";
              example = "npx -y @anthropic-ai/mcp-server-filesystem /path/to/allowed/files";
            };

            url = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "URL for HTTP/SSE transport";
              example = "https://mcp.example.com/sse";
            };

            transport = lib.mkOption {
              type = lib.types.enum [
                "stdio"
                "http"
                "sse"
              ];
              default = "stdio";
              description = "Transport type for the MCP server";
            };

            env = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              description = "Environment variables for the MCP server";
              example = {
                "API_KEY" = "your-api-key";
                "BASE_URL" = "https://api.example.com";
              };
            };

            scope = lib.mkOption {
              type = lib.types.enum [
                "user"
                "project"
                "local"
              ];
              default = "user";
              description = "Configuration scope for the MCP server";
            };
          };
        };
      in
      lib.mkOption {
        type = lib.types.attrsOf mcpServerType;
        default = { };
        description = ''
          MCP (Model Context Protocol) servers configuration.
          These servers extend Claude Code's capabilities with external tools and data sources.
        '';
        example = lib.literalExpression ''
          {
            filesystem = {
              command = "npx -y @anthropic-ai/mcp-server-filesystem /home/user/projects";
              transport = "stdio";
              scope = "project";
            };
            github = {
              url = "https://mcp.github.com/sse";
              transport = "sse";
              env = {
                "GITHUB_TOKEN" = "ghp_your_token_here";
              };
            };
          }
        '';
      };

    hooks = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      description = ''
        Hook configurations that execute shell commands in response to events.
        Hooks can be used to create custom commands and automation.
      '';
      example = lib.literalExpression ''
        {
          "user-prompt-submit-hook" = {
            "command": "echo 'User submitted: $CLAUDE_USER_PROMPT'",
            "description": "Log user prompts"
          }
        }
      '';
    };

    commands = lib.mkOption {
      type = lib.types.attrsOf lib.types.lines;
      default = { };
      description = ''
        Custom commands for Claude Code.
        The attribute name becomes the command filename, and the value is the file content.
        Commands are stored in .claude/commands/ directory.
      '';
      example = lib.literalExpression ''
        {
          changelog = '''
            Parse the version, change type, and message from the input
            and update the CHANGELOG.md file accordingly.
          ''';
          review = '''
            Analyze the staged git changes and provide a thorough
            code review with suggestions for improvement.
          ''';
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = lib.mkIf (cfg.package != null) [ cfg.package ];

      file = {
        ".claude/settings.json" = lib.mkIf (cfg.settings != { }) {
          source = jsonFormat.generate "claude-code-settings.json" cfg.settings;
        };

        ".claude/settings.local.json" = lib.mkIf (cfg.localSettings != { }) {
          source = jsonFormat.generate "claude-code-local-settings.json" cfg.localSettings;
        };

        ".claude/hooks.json" = lib.mkIf (cfg.hooks != { }) {
          source = jsonFormat.generate "claude-code-hooks.json" cfg.hooks;
        };

        ".claude/mcp.json" = lib.mkIf (cfg.mcpServers != { }) {
          source = jsonFormat.generate "claude-code-mcp.json" (
            lib.mapAttrs (
              _: server:
              lib.filterAttrs (_: value: value != null) (
                {
                  inherit (server) transport scope;
                }
                // lib.optionalAttrs (server.command != null) { inherit (server) command; }
                // lib.optionalAttrs (server.url != null) { inherit (server) url; }
                // lib.optionalAttrs (server.env != { }) { inherit (server) env; }
              )
            ) cfg.mcpServers
          );
        };
      }
      // lib.mapAttrs' (
        name: agent:
        lib.nameValuePair ".claude/agents/${name}.md" {
          text =
            let
              frontmatter = lib.concatStringsSep "\n" (
                [ "description: ${agent.description}" ]
                ++ lib.optional (agent.model != null) "model: ${agent.model}"
                ++
                  lib.optional (agent.tools != [ ])
                    "tools: [${lib.concatStringsSep ", " (map (tool: "\"${tool}\"") agent.tools)}]"
              );
            in
            ''
              ---
              ${frontmatter}
              ---

              ${agent.prompt}'';
        }
      ) cfg.agents
      // lib.mapAttrs' (
        name: content:
        lib.nameValuePair ".claude/commands/${name}" {
          text = content;
        }
      ) cfg.commands;
    };
  };
}
