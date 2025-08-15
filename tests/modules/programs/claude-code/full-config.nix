{
  programs.claude-code = {
    enable = true;

    settings = {
      theme = "dark";
      permissions = {
        bash = "allow";
        edit = "allow";
      };
      model = "claude-3-5-sonnet-20241022";
    };

    localSettings = {
      anthropic_api_key = "test-api-key";
    };

    hooks = {
      user-prompt-submit-hook = {
        command = "echo 'User submitted: $CLAUDE_USER_PROMPT'";
        description = "Log user prompts";
      };
    };

    commands = {
      changelog = ''
        Parse the version, change type, and message from the input
        and update the CHANGELOG.md file accordingly.
      '';
      review = ''
        Analyze the staged git changes and provide a thorough
        code review with suggestions for improvement.
      '';
    };

    agents = {
      code-reviewer = {
        description = "Specialized code review agent";
        prompt = ''
          You are a senior software engineer specializing in code reviews.
          Focus on code quality, security, and maintainability.
        '';
        tools = [
          "Read"
          "Edit"
          "Grep"
        ];
      };

      documentation = {
        description = "Documentation writing assistant";
        prompt = ''
          You are a technical writer who creates clear, comprehensive documentation.
          Focus on user-friendly explanations and examples.
        '';
        tools = [
          "Read"
          "Write"
          "Edit"
        ];
        model = "claude-3-5-sonnet-20241022";
      };
    };

    mcpServers = {
      filesystem = {
        command = "npx -y @anthropic-ai/mcp-server-filesystem /home/user/projects";
        transport = "stdio";
        scope = "project";
      };

      github = {
        url = "https://mcp.github.com/sse";
        transport = "sse";
        env = {
          GITHUB_TOKEN = "ghp_your_token_here";
        };
        scope = "user";
      };
    };
  };

  nmt.script = ''
    assertFileExists home-files/.claude/settings.json
    assertFileContent home-files/.claude/settings.json ${./expected-settings.json}

    assertFileExists home-files/.claude/settings.local.json
    assertFileContent home-files/.claude/settings.local.json ${./expected-local-settings.json}

    assertFileExists home-files/.claude/hooks.json
    assertFileContent home-files/.claude/hooks.json ${./expected-hooks.json}

    assertFileExists home-files/.claude/agents/code-reviewer.md
    assertFileContent home-files/.claude/agents/code-reviewer.md ${./expected-code-reviewer.md}

    assertFileExists home-files/.claude/agents/documentation.md
    assertFileContent home-files/.claude/agents/documentation.md ${./expected-documentation.md}

    assertFileExists home-files/.claude/mcp.json
    assertFileContent home-files/.claude/mcp.json ${./expected-mcp.json}

    assertFileExists home-files/.claude/commands/changelog
    assertFileContent home-files/.claude/commands/changelog ${./expected-changelog}

    assertFileExists home-files/.claude/commands/review
    assertFileContent home-files/.claude/commands/review ${./expected-review}
  '';
}
