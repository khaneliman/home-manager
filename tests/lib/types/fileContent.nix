{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) hm mkOption;
in
{
  options.programs.my-program.files = mkOption {
    description = "Configuration files for my-program.";
    type = lib.types.attrsOf hm.types.fileContent;
    default = { };
    example = ''
      {
        # Simple string for inline content
        "config.toml" = '''
          # My program config
          enabled = true;
        ''';

        # A path to a source file
        "data/database.sqlite" = ./local-db.sqlite;

        # A path to a directory (will be copied recursively by default)
        "themes" = ./my-themes-dir;

        # A full spec for more control
        "script.sh" = {
          source = ./my-script.sh;
          executable = true;
        };

        # A recursive directory where you want to override the default
        "assets" = {
          source = ./assets-dir;
          recursive = false; # Only link the top-level directory
        };
      }
    '';
  };

  config =
    let
      testDir = pkgs.runCommand "test-directory" { } ''
        mkdir -p $out/subdir
        echo "main config content" > $out/main.conf
        echo "sub config content" > $out/subdir/sub.conf
        chmod +x $out/main.conf
      '';
    in
    {
      programs.my-program.files = {
        # Simple string content - should convert to { text = "..."; }
        "config.toml" = ''
          # My program config
          enabled = true
          port = 8080

          [database]
          host = "localhost"
          name = "myapp"
        '';

        # Path to a file - should convert to { source = ./path; }
        "data/init.sql" = pkgs.writeText "init.sql" ''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
          );
          INSERT INTO users (name) VALUES ('test user');
        '';

        # Full attribute set with text
        "scripts/setup.sh" = {
          text = ''
            #!/bin/bash
            echo "Setting up application..."
            mkdir -p ~/.local/share/my-program
          '';
          executable = true;
        };

        # Full attribute set with source file
        "config/advanced.conf" = {
          source = pkgs.writeText "advanced.conf" ''
            # Advanced configuration
            max_connections = 100
            timeout = 30s
          '';
          executable = false;
        };

        # Test directory path - explicit directory handling since pathIsDirectory
        # doesn't work reliably on derivation paths at evaluation time
        "test-dir-recursive" = {
          source = testDir;
          recursive = true;
        };

        # Directory with explicit recursive = false override
        "test-dir-non-recursive" = {
          source = testDir;
          recursive = false;
        };

        # Test with actual filesystem path (this should auto-detect directory)
        "filesystem-dir" = ./.;

        # Test mixed attribute set with both text and other options
        "mixed-attrs-text" = {
          text = "Mixed content with text";
          executable = true;
          # Note: recursive should be ignored when text is used
          recursive = true;
        };

        # Test mixed attribute set with both source and other options
        "mixed-attrs-source" = {
          source = pkgs.writeText "mixed-source.txt" "Source content";
          executable = false;
          recursive = false;
        };

        # Test fileContentToHomeFile helper with string
        "helper-string" = lib.hm.types.fileContentToHomeFile "helper string content";

        # Test fileContentToHomeFile helper with path
        "helper-path" = lib.hm.types.fileContentToHomeFile (
          pkgs.writeText "helper-path.txt" "helper path content"
        );

        # Test fileContentToHomeFile helper with directory (explicit since derivation paths can't auto-detect)
        "helper-dir" = lib.hm.types.fileContentToHomeFile {
          source = testDir;
          recursive = true;
        };

        # Test fileContentToHomeFile helper with attribute set
        "helper-attrs" = lib.hm.types.fileContentToHomeFile {
          text = "helper attrs content";
          executable = true;
        };

        # Test null values in attribute set (should be filtered out)
        "null-values" = {
          text = "content with nulls";
          source = null;
          executable = false;
        };

        # Test empty string (edge case)
        "empty-string" = "";

        # Test single line string
        "single-line" = "single line content";

        # Test enhanced script generation features
        "bash-script" = {
          text = ''
            echo "Hello from bash!"
            date
          '';
          scriptType = "bash";
        };

        "lua-script" = {
          text = ''
            print("Hello from lua!")
            os.date()
          '';
          scriptType = "lua";
        };

        "script-with-template" = {
          text = ''
            echo "Main script content"
          '';
          scriptType = "bash";
          template = {
            header = "# Generated configuration script";
            footer = "# End of generated script";
          };
        };

        "template-only" = {
          text = "Some content";
          template = {
            header = "# Header comment";
            footer = "# Footer comment";
          };
        };

        "python-script" = {
          text = ''
            print("Hello from Python!")
            import datetime
            print(datetime.datetime.now())
          '';
          scriptType = "python";
        };
      };

      # Map the files to home.file to test the actual file generation
      # Using fileContentToHomeFile helper to process enhanced attributes
      home.file = lib.mapAttrs' (
        path: value:
        lib.nameValuePair ".config/my-program/${path}" (lib.hm.types.fileContentToHomeFile value)
      ) config.programs.my-program.files;

      nmt.script = ''
        # Test that all basic files were created
        assertFileExists home-files/.config/my-program/config.toml
        assertFileExists home-files/.config/my-program/data/init.sql
        assertFileExists home-files/.config/my-program/scripts/setup.sh
        assertFileExists home-files/.config/my-program/config/advanced.conf

        # Test directory handling
        assertDirectoryExists home-files/.config/my-program/test-dir-recursive
        assertFileExists home-files/.config/my-program/test-dir-recursive/main.conf
        assertFileExists home-files/.config/my-program/test-dir-recursive/subdir/sub.conf

        assertDirectoryExists home-files/.config/my-program/test-dir-non-recursive
        # Note: non-recursive should still copy content in nix context

        assertDirectoryExists home-files/.config/my-program/filesystem-dir
        # Filesystem directory should auto-detect and be recursive

        # Test helper function results
        assertFileExists home-files/.config/my-program/helper-string
        assertFileExists home-files/.config/my-program/helper-path
        assertDirectoryExists home-files/.config/my-program/helper-dir
        assertFileExists home-files/.config/my-program/helper-attrs

        # Test edge cases
        assertFileExists home-files/.config/my-program/null-values
        assertFileExists home-files/.config/my-program/empty-string
        assertFileExists home-files/.config/my-program/single-line

        # Test mixed attribute sets
        assertFileExists home-files/.config/my-program/mixed-attrs-text
        assertFileExists home-files/.config/my-program/mixed-attrs-source

        # Test enhanced script generation features
        assertFileExists home-files/.config/my-program/bash-script
        assertFileExists home-files/.config/my-program/lua-script
        assertFileExists home-files/.config/my-program/script-with-template
        assertFileExists home-files/.config/my-program/template-only
        assertFileExists home-files/.config/my-program/python-script

        # Test content of string-based file
        assertFileContent home-files/.config/my-program/config.toml ${pkgs.writeText "expected-config.toml" ''
          # My program config
          enabled = true
          port = 8080

          [database]
          host = "localhost"
          name = "myapp"
        ''}

        # Test content of source-based file
        assertFileContent home-files/.config/my-program/data/init.sql ${pkgs.writeText "expected-init.sql" ''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
          );
          INSERT INTO users (name) VALUES ('test user');
        ''}

        # Test that the setup script is executable
        assertFileIsExecutable home-files/.config/my-program/scripts/setup.sh

        # Test content of executable script
        assertFileContent home-files/.config/my-program/scripts/setup.sh ${pkgs.writeText "expected-setup.sh" ''
          #!/bin/bash
          echo "Setting up application..."
          mkdir -p ~/.local/share/my-program
        ''}

        # Test that advanced.conf is not executable (default)
        if [[ -x home-files/.config/my-program/config/advanced.conf ]]; then
          fail "advanced.conf should not be executable"
        fi

        # Test content of advanced config
        assertFileContent home-files/.config/my-program/config/advanced.conf ${pkgs.writeText "expected-advanced.conf" ''
          # Advanced configuration
          max_connections = 100
          timeout = 30s
        ''}

        # Test content of directory files
        assertFileContent home-files/.config/my-program/test-dir-recursive/main.conf ${pkgs.writeText "expected-main" "main config content\n"}
        assertFileContent home-files/.config/my-program/test-dir-recursive/subdir/sub.conf ${pkgs.writeText "expected-sub" "sub config content\n"}

        # Test helper function content
        assertFileContent home-files/.config/my-program/helper-string ${pkgs.writeText "expected-helper-string" "helper string content"}
        assertFileContent home-files/.config/my-program/helper-path ${pkgs.writeText "expected-helper-path" "helper path content"}
        assertFileContent home-files/.config/my-program/helper-attrs ${pkgs.writeText "expected-helper-attrs" "helper attrs content"}

        # Test mixed attribute sets content
        assertFileContent home-files/.config/my-program/mixed-attrs-text ${pkgs.writeText "expected-mixed-text" "Mixed content with text"}
        assertFileContent home-files/.config/my-program/mixed-attrs-source ${pkgs.writeText "expected-mixed-source" "Source content"}

        # Test edge cases content
        assertFileContent home-files/.config/my-program/null-values ${pkgs.writeText "expected-null" "content with nulls"}
        assertFileContent home-files/.config/my-program/empty-string ${pkgs.writeText "expected-empty" ""}
        assertFileContent home-files/.config/my-program/single-line ${pkgs.writeText "expected-single" "single line content"}

        # Test enhanced script generation content
        assertFileContent home-files/.config/my-program/bash-script ${pkgs.writeText "expected-bash-script" ''
          #!/usr/bin/env bash
          echo "Hello from bash!"
          date
        ''}

        assertFileContent home-files/.config/my-program/lua-script ${pkgs.writeText "expected-lua-script" ''
          #!/usr/bin/env lua
          print("Hello from lua!")
          os.date()
        ''}

        assertFileContent home-files/.config/my-program/script-with-template ${pkgs.writeText "expected-script-template" ''
          #!/usr/bin/env bash
          # Generated configuration script
          echo "Main script content"

          # End of generated script''}

        assertFileContent home-files/.config/my-program/template-only ${pkgs.writeText "expected-template-only" ''
          # Header comment
          Some content
          # Footer comment''}

        assertFileContent home-files/.config/my-program/python-script ${pkgs.writeText "expected-python-script" ''
          #!/usr/bin/env python3
          print("Hello from Python!")
          import datetime
          print(datetime.datetime.now())
        ''}

        # Test executable flags
        assertFileIsExecutable home-files/.config/my-program/mixed-attrs-text
        assertFileIsExecutable home-files/.config/my-program/helper-attrs

        # Test that script types are automatically executable
        assertFileIsExecutable home-files/.config/my-program/bash-script
        assertFileIsExecutable home-files/.config/my-program/lua-script
        assertFileIsExecutable home-files/.config/my-program/python-script
        assertFileIsExecutable home-files/.config/my-program/script-with-template

        # Test non-executable files
        if [[ -x home-files/.config/my-program/mixed-attrs-source ]]; then
          fail "mixed-attrs-source should not be executable"
        fi
        if [[ -x home-files/.config/my-program/null-values ]]; then
          fail "null-values should not be executable (default)"
        fi
        if [[ -x home-files/.config/my-program/template-only ]]; then
          fail "template-only should not be executable (only scriptType makes it executable)"
        fi

        # Note: Directory executable permissions from source aren't always preserved
        # by home-manager's file generation, so we don't test that here
      '';
    };
}
