{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (lib.generators) toPlist;

  cfg = config.launchd;
  labelPrefix = "org.nix-community.home.";
  dstDir = "${config.home.homeDirectory}/Library/LaunchAgents";

  launchdConfig = { config, name, ... }: {
    options = {
      enable = mkEnableOption name;
      config = mkOption {
        type = types.submodule (import ./launchd.nix);
        default = { };
        example = literalExpression ''
          {
            ProgramArguments = [ "/usr/bin/say" "Good afternoon" ];
            StartCalendarInterval = [
              {
                Hour = 12;
                Minute = 0;
              }
            ];
          }
        '';
        description = ''
          Define a launchd job. See {manpage}`launchd.plist(5)` for details.
        '';
      };
    };

    config = { config.Label = mkDefault "${labelPrefix}${name}"; };
  };

  toAgent = config: pkgs.writeText "${config.Label}.plist" (toPlist { } config);

  agentPlists =
    mapAttrs' (n: v: nameValuePair "${v.config.Label}.plist" (toAgent v.config))
    (filterAttrs (n: v: v.enable) cfg.agents);

  agentsDrv = pkgs.runCommand "home-manager-agents" { } ''
    mkdir -p "$out"

    declare -A plists
    plists=(${
      concatStringsSep " "
      (mapAttrsToList (name: value: "['${name}']='${value}'") agentPlists)
    })

    for dest in "''${!plists[@]}"; do
      src="''${plists[$dest]}"
      ln -s "$src" "$out/$dest"
    done
  '';
in {
  meta.maintainers = with maintainers; [ midchildan ];

  options.launchd = {
    enable = mkOption {
      type = types.bool;
      default = isDarwin;
      defaultText = literalExpression "pkgs.stdenv.hostPlatform.isDarwin";
      description = ''
        Whether to enable Home Manager to define per-user daemons by making use
        of launchd's LaunchAgents.
      '';
    };

    agents = mkOption {
      type = with types; attrsOf (submodule launchdConfig);
      default = { };
      description = "Define LaunchAgents.";
    };
  };

  config = mkMerge [
    {
      assertions = [{
        assertion = (cfg.enable && agentPlists != { }) -> isDarwin;
        message = let names = lib.concatStringsSep ", " (attrNames agentPlists);
        in "Must use Darwin for modules that require Launchd: " + names;
      }];
    }

    (mkIf isDarwin {
      home.extraBuilderCommands = ''
        ln -s "${agentsDrv}" $out/LaunchAgents
      '';

      home.activation.checkLaunchAgents =
        hm.dag.entryBefore [ "writeBoundary" ] ''
          checkLaunchAgents() {
            echo "Checking LaunchAgents for conflicts..."
            local oldDir newDir dstDir err
            oldDir=""
            err=0
            if [[ -n "''${oldGenPath:-}" ]]; then
              verboseEcho "Previous generation path found: $oldGenPath"
              oldDir="$(readlink -m "$oldGenPath/LaunchAgents")" || err=$?
              if (( err )); then
                verboseEcho "Failed to resolve previous LaunchAgents directory, assuming first run"
                oldDir=""
              else
                verboseEcho "Previous LaunchAgents directory: $oldDir"
              fi
            else
              verboseEcho "No previous generation path found, assuming first run"
            fi
            newDir=${escapeShellArg agentsDrv}
            dstDir=${escapeShellArg dstDir}
            verboseEcho "New LaunchAgents directory: $newDir"
            verboseEcho "Destination directory: $dstDir"

            local oldSrcPath newSrcPath dstPath agentFile agentName
            local agentCount=0
            local conflictCount=0

            echo "Scanning for potential LaunchAgent conflicts..."

            # Check if there are any plist files to process
            if ! find -L "$newDir" -maxdepth 1 -name '*.plist' -type f | grep -q .; then
              echo "No LaunchAgent plist files found in $newDir"
              echo "LaunchAgent check complete. No agents to examine."
              return 0
            fi

            find -L "$newDir" -maxdepth 1 -name '*.plist' -type f -print0 \
                | while IFS= read -rd "" newSrcPath; do
              agentFile="''${newSrcPath##*/}"
              agentName="''${agentFile%.plist}"
              dstPath="$dstDir/$agentFile"
              oldSrcPath="$oldDir/$agentFile"

              (( agentCount++ ))
              verboseEcho "Checking agent: $agentName"

              if [[ ! -e "$dstPath" ]]; then
                verboseEcho "  - No existing file at $dstPath, will be created"
                continue
              fi

              verboseEcho "  - Existing file found at $dstPath"
              if [[ -z "$oldDir" || ! -e "$oldSrcPath" ]]; then
                verboseEcho "  - No previous version to compare with"
                (( conflictCount++ ))
                errorEcho "Existing file '$dstPath' is in the way of '$newSrcPath'"
                errorEcho "This file was not created by Home Manager or has been modified outside of Home Manager"
                exit 1
              fi

              if ! cmp --quiet "$oldSrcPath" "$dstPath"; then
                verboseEcho "  - File has been modified since last generation"
                (( conflictCount++ ))
                errorEcho "Existing file '$dstPath' is in the way of '$newSrcPath'"
                errorEcho "This file has been modified outside of Home Manager"
                exit 1
              else
                verboseEcho "  - File matches previous generation, no conflict"
              fi
            done

            echo "LaunchAgent check complete. Examined $agentCount agents, found $conflictCount conflicts."
          }

          if [[ -v DRY_RUN ]]; then
            echo "Would check LaunchAgents for conflicts"
          else
            checkLaunchAgents
          fi
        '';

      # NOTE: Launch Agent configurations can't be symlinked from the Nix store
      # because it needs to be owned by the user running it.
      home.activation.setupLaunchAgents =
        hm.dag.entryAfter [ "writeBoundary" ] ''
          setupLaunchAgents() {
            echo "Setting up LaunchAgents..."
            local oldDir newDir dstDir domain err
            oldDir=""
            err=0
            if [[ -n "''${oldGenPath:-}" ]]; then
              oldDir="$(readlink -m "$oldGenPath/LaunchAgents")" || err=$?
              if (( err )); then
                verboseEcho "Failed to resolve previous LaunchAgents directory, assuming first run"
                oldDir=""
              fi
            fi
            newDir="$(readlink -m "$newGenPath/LaunchAgents")"
            dstDir=${escapeShellArg dstDir}
            domain="gui/$UID"
            err=0

            local srcPath dstPath agentFile agentName i bootout_retries
            bootout_retries=10
            local agentCount=0
            local updatedCount=0
            local removedCount=0

            # Check if there are any plist files to process
            if ! find -L "$newDir" -maxdepth 1 -name '*.plist' -type f | grep -q .; then
              echo "No LaunchAgent plist files found in $newDir"

              # Check if we need to clean up old agents
              if [[ -e "$oldDir" ]] && find -L "$oldDir" -maxdepth 1 -name '*.plist' -type f | grep -q .; then
                echo "Checking for obsolete LaunchAgents to remove..."
              else
                echo "No LaunchAgents to set up or remove."
                return 0
              fi
            else
              echo "Processing LaunchAgents..."
            fi

            find -L "$newDir" -maxdepth 1 -name '*.plist' -type f -print0 \
                | while IFS= read -rd "" srcPath; do
              agentFile="''${srcPath##*/}"
              agentName="''${agentFile%.plist}"
              dstPath="$dstDir/$agentFile"
              (( agentCount++ ))

              verboseEcho "Processing agent: $agentName"

              if cmp --quiet "$srcPath" "$dstPath"; then
                verboseEcho "  - Agent is already up to date, skipping"
                continue
              fi

              (( updatedCount++ ))
              verboseEcho "  - Agent needs updating"

              if [[ -f "$dstPath" ]]; then
                verboseEcho "  - Stopping existing agent"
                for (( i = 0; i < bootout_retries; i++ )); do
                  run /bin/launchctl bootout "$domain/$agentName" || err=$?
                  if [[ -v DRY_RUN ]]; then
                    break
                  fi
                  if (( err != 9216 )) &&
                    ! /bin/launchctl print "$domain/$agentName" &> /dev/null; then
                    break
                  fi
                  verboseEcho "    - Waiting for agent to stop (attempt $((i+1))/$bootout_retries)"
                  sleep 1
                done
                if (( i == bootout_retries )); then
                  warnEcho "Failed to stop '$domain/$agentName'"
                  return 1
                fi
              fi
              verboseEcho "  - Installing agent file"
              run install -Dm444 -T "$srcPath" "$dstPath"
              verboseEcho "  - Starting agent"
              run /bin/launchctl bootstrap "$domain" "$dstPath"
            done

            if [[ ! -e "$oldDir" ]]; then
              if (( agentCount > 0 )); then
                echo "LaunchAgent setup complete. Processed $agentCount agents, updated $updatedCount."
              fi
              return 0
            fi

            # Check for agents to remove
            local oldAgentCount=0
            oldAgentCount=$(find -L "$oldDir" -maxdepth 1 -name '*.plist' -type f | wc -l)
            if (( oldAgentCount > 0 )); then
              verboseEcho "Checking for obsolete LaunchAgents..."

              find -L "$oldDir" -maxdepth 1 -name '*.plist' -type f -print0 \
                  | while IFS= read -rd "" srcPath; do
                agentFile="''${srcPath##*/}"
                agentName="''${agentFile%.plist}"
                dstPath="$dstDir/$agentFile"
                if [[ -e "$newDir/$agentFile" ]]; then
                  continue
                fi

                verboseEcho "Removing agent: $agentName"
                run /bin/launchctl bootout "$domain/$agentName" || :
                if [[ ! -e "$dstPath" ]]; then
                  verboseEcho "  - Agent file already removed"
                  continue
                fi
                if ! cmp --quiet "$srcPath" "$dstPath"; then
                  warnEcho "Skipping deletion of '$dstPath', since its contents have diverged"
                  continue
                fi
                (( removedCount++ ))
                verboseEcho "  - Removing agent file"
                run rm -f $VERBOSE_ARG "$dstPath"
              done
            fi

            if (( agentCount > 0 || removedCount > 0 )); then
              echo "LaunchAgent setup complete. Processed $agentCount agents, updated $updatedCount, removed $removedCount."
            else
              echo "LaunchAgent setup complete. No changes needed."
            fi
          }

          setupLaunchAgents
        '';
    })
  ];
}
