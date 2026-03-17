{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.targets.darwin.copyApps;
in
{
  options.targets.darwin.copyApps = {
    enable =
      lib.mkEnableOption "copying macOS applications to the user environment (works with Spotlight)"
      // {
        default =
          pkgs.stdenv.hostPlatform.isDarwin && (lib.versionAtLeast config.home.stateVersion "25.11");
        defaultText = lib.literalExpression ''pkgs.stdenv.hostPlatform.isDarwin && (lib.versionAtLeast config.home.stateVersion "25.11")'';
      };

    enableChecks = lib.mkEnableOption "enable App Management checks" // {
      default = true;
    };

    directory = lib.mkOption {
      type = lib.types.str;
      default = "Applications/Home Manager Apps";
      description = "Path to link apps relative to the home directory.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.targets.darwin.linkApps.enable;
        message = "`targets.darwin.copyApps.enable` conflicts with `targets.darwin.linkApps.enable`. Please disable one of them.";
      }
      (lib.hm.assertions.assertPlatform "targets.darwin.copyApps" pkgs lib.platforms.darwin)
    ];

    home.activation.copyApps = lib.hm.dag.entryAfter [ "installPackages" ] (
      let
        applications = pkgs.buildEnv {
          name = "home-manager-applications";
          paths = config.home.packages;
          pathsToLink = [ "/Applications" ];
        };
      in
      # bash
      ''
        targetFolder='${cfg.directory}'
        targetParent="$(dirname "$targetFolder")"
        targetName="$(basename "$targetFolder")"

        echo "setting up ~/$targetFolder..." >&2

        # `linkApps` used to manage this path as a symlink into the Nix store.
        # Remove the old target and replace the whole directory atomically
        # instead of mutating app bundles in place.
        ourLink() {
          local link
          link=$(readlink "$1")
          [ -L "$1" ] && [ "''${link#*-}" = 'home-manager-applications/Applications' ]
        }

        run mkdir -p "$targetParent"

          tmpTarget="$(mktemp -d "$targetParent/.''${targetName}.tmp.XXXXXX")"

        rsyncFlags=(
          # mtime is standardized in the nix store, which would leave only file size to distinguish files.
          # Thus we need checksums, despite the speed penalty.
          --checksum
          # Converts all symlinks pointing outside of the copied tree (thus unsafe) into real files and directories.
          # This neatly converts all the symlinks pointing to application bundles in the nix store into
          # real directories, without breaking any relative symlinks inside of application bundles.
          # This is good enough, because the make-symlinks-relative.sh setup hook converts all $out internal
          # symlinks to relative ones.
          --copy-unsafe-links
          --archive
          --delete
          --chmod=+w
          --no-group
          --no-owner
        )

        run ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" ${applications}/Applications/ "$tmpTarget/"

        if [ -e "$targetFolder" ]; then
          if ourLink "$targetFolder"; then
            run rm "$targetFolder"
          else
            run rm -rf "$targetFolder"
          fi
        fi

        run mv "$tmpTarget" "$targetFolder"
      ''
    );
  };
}
