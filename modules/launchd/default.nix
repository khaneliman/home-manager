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

      # NOTE: Launch Agent configurations can't be symlinked from the Nix store
      # because it needs to be owned by the user running it.
      home.activation.setupLaunchAgents =
        hm.dag.entryAfter [ "writeBoundary" ] # Bash
        ''
          # Initialize variables for tracking agent status
          updated_count=0
          failed_count=0
          removed_count=0

          bootoutAgent() {
            local domain="$1"
            local agentName="$2"
            local bootout_retries=10
            local err=0
            local i

            verboseEcho "Stopping agent '$domain/$agentName'..."
            for (( i = 0; i < bootout_retries; i++ )); do
              if (( i > 0 )); then
                verboseEcho "Retry $i/$bootout_retries stopping agent '$agentName'..."
              fi

              run /bin/launchctl bootout "$domain/$agentName" || err=$?

              if [[ -v DRY_RUN ]]; then
                verboseEcho "DRY_RUN: Would stop agent '$agentName'"
                return 0
              fi

              if (( err != 9216 )) &&
                ! run /bin/launchctl print "$domain/$agentName" &> /dev/null; then
                verboseEcho "Successfully stopped agent '$agentName'"
                return 0
              fi

              if (( i < bootout_retries - 1 )); then
                verboseEcho "Agent '$agentName' still running, waiting before retry..."
                sleep 1
              fi
            done

            if (( i == bootout_retries )); then
              warnEcho "Failed to stop agent '$domain/$agentName' after $bootout_retries attempts"
              return 1
            fi

            return 0
          }

          installAndBootstrapAgent() {
            local domain="$1"
            local srcPath="$2"
            local dstPath="$3"
            local agentName="$4"

            verboseEcho "Installing agent file to $dstPath"
            run install -Dm444 -T "$srcPath" "$dstPath"

            verboseEcho "Bootstrapping agent '$domain/$agentName'"
            if ! run /bin/launchctl bootstrap "$domain" "$dstPath"; then
              errorEcho "Failed to bootstrap agent '$domain/$agentName'"
              return 1
            else
              verboseEcho "Successfully bootstrapped agent '$domain/$agentName'"
              return 0
            fi
          }

          processAgent() {
            local domain="$1"
            local srcPath="$2"
            local dstPath="$3"
            local agentFile="$4"
            local agentName="$5"

            if cmp -s "$srcPath" "$dstPath"; then
              verboseEcho "Agent '$domain/$agentName' is already up-to-date"
              return 0
            fi

            verboseEcho "Processing agent '$agentName'"

            if [[ -f "$dstPath" ]]; then
              if ! bootoutAgent "$domain" "$agentName"; then
                (( failed_count++ ))
                return 1
              fi
            else
              verboseEcho "Installing new agent '$agentName'"
            fi

            if installAndBootstrapAgent "$domain" "$srcPath" "$dstPath" "$agentName"; then
              (( updated_count++ ))
              return 0
            else
              (( failed_count++ ))
              return 1
            fi
          }

          removeAgent() {
            local domain="$1"
            local srcPath="$2"
            local dstPath="$3"
            local agentName="$4"

            verboseEcho "Removing agent '$domain/$agentName'..."
            if ! run /bin/launchctl bootout "$domain/$agentName"; then
              warnEcho "Failed to stop agent '$domain/$agentName', it may already be stopped"
            else
              verboseEcho "Successfully stopped agent '$domain/$agentName'"
            fi

            if [[ ! -e "$dstPath" ]]; then
              verboseEcho "Agent file '$dstPath' already removed"
              return 0
            fi

            if ! cmp -s "$srcPath" "$dstPath"; then
              warnEcho "Skipping deletion of '$dstPath', since its contents have diverged"
              return 0
            fi

            verboseEcho "Removing agent file '$dstPath'"
            if run rm -f $VERBOSE_ARG "$dstPath"; then
              verboseEcho "Successfully removed agent file for '$agentName'"
              (( removed_count++ ))
              return 0
            else
              warnEcho "Failed to remove agent file '$dstPath'"
              return 1
            fi
          }

          setupLaunchAgents() {
            local oldDir newDir dstDir domain err
            oldDir=""
            err=0

            # Find the old and new LaunchAgents directories
            if [[ -n "''${oldGenPath:-}" ]]; then
              oldDir="$(readlink -m "$oldGenPath/LaunchAgents")" || err=$?
              verboseEcho $oldDir
              if (( err )); then
                oldDir=""
                verboseEcho "No previous LaunchAgents directory found"
              fi
            fi

            newDir="$(readlink -m "$newGenPath/LaunchAgents")"
            dstDir=${escapeShellArg dstDir}
            domain="gui/$UID"
            err=0

            verboseEcho "Setting up LaunchAgents in $dstDir"
            [[ -d "$dstDir" ]] || run mkdir -p "$dstDir"

            # Process new and updated agents
            verboseEcho "Processing new/updated LaunchAgents..."
            local newAgents=()
            while IFS= read -rd "" srcPath; do
              newAgents+=("$srcPath")
            done < <(find -L "$newDir" -maxdepth 1 -name '*.plist' -type f -print0)

            for srcPath in "''${newAgents[@]}"; do
              agentFile="''${srcPath##*/}"
              agentName="''${agentFile%.plist}"
              dstPath="$dstDir/$agentFile"

              processAgent "$domain" "$srcPath" "$dstPath" "$agentFile" "$agentName"
            done

            # Skip cleanup if there's no previous generation
            if [[ ! -e "$oldDir" ]]; then
              verboseEcho "LaunchAgents setup complete: $updated_count updated, $failed_count failed"
              return
            fi

            # Clean up removed agents
            verboseEcho "Cleaning up removed LaunchAgents..."
            local oldAgents=()
            while IFS= read -rd "" srcPath; do
              oldAgents+=("$srcPath")
            done < <(find -L "$oldDir" -maxdepth 1 -name '*.plist' -type f -print0)

            for srcPath in "''${oldAgents[@]}"; do
              agentFile="''${srcPath##*/}"
              agentName="''${agentFile%.plist}"
              dstPath="$dstDir/$agentFile"

              if [[ -e "$newDir/$agentFile" ]]; then
                verboseEcho "Agent '$agentName' still exists in new generation, skipping cleanup"
                continue
              fi

              removeAgent "$domain" "$srcPath" "$dstPath" "$agentName"
            done

            verboseEcho "LaunchAgents setup complete: $updated_count updated, $removed_count removed, $failed_count failed"
          }

          setupLaunchAgents
        '';
    })
  ];
}
