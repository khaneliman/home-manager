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

  config = {
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

      # Path to a directory (would be recursive by default if it was a real directory)
      "themes" = pkgs.writeText "theme.css" ''
        .dark-theme { background: #1a1a1a; color: #ffffff; }
        .light-theme { background: #ffffff; color: #000000; }
      '';

      # Directory with explicit recursive control
      "assets" = {
        source = pkgs.writeText "asset.txt" "Sample asset content";
        recursive = false;
      };
    };

    # Map the files to home.file to test the actual file generation
    home.file = lib.mapAttrs' (
      path: value: lib.nameValuePair ".config/my-program/${path}" value
    ) config.programs.my-program.files;

    nmt.script = ''
      # Test that all files were created
      assertFileExists home-files/.config/my-program/config.toml
      assertFileExists home-files/.config/my-program/data/init.sql
      assertFileExists home-files/.config/my-program/scripts/setup.sh
      assertFileExists home-files/.config/my-program/config/advanced.conf
      assertFileExists home-files/.config/my-program/themes
      assertFileExists home-files/.config/my-program/assets

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
    '';
  };
}
