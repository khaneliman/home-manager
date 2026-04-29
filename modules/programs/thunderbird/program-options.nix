{
  config,
  lib,
  pkgs,
  isDarwin,
  moduleName,
}:
let
  inherit (lib)
    literalExpression
    mkOption
    types
    ;

  cfg = config.programs.thunderbird;

  jsonFormat = pkgs.formats.json { };

  thunderbirdJson = types.attrsOf jsonFormat.type // {
    description = "Thunderbird preference (int, bool, string, and also attrs, list, float as a JSON string)";
  };
in
{
  programs.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird";

    package = lib.mkPackageOption pkgs "thunderbird" {
      example = "pkgs.thunderbird-91";
    };

    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
      description = "Resulting Thunderbird package.";
    };

    release = mkOption {
      internal = true;
      type = types.str;
      description = ''
        Upstream release version used to fetch language packs from
        `releases.mozilla.org`.
      '';
    };

    languagePacks = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Thunderbird language packs to install and activate through enterprise
        policies.

        Available language codes can be found on the releases page:
        `https://releases.mozilla.org/pub/thunderbird/releases/''${version}/linux-x86_64/xpi/`,
        replacing `''${version}` with the version of Thunderbird you have. If
        the version string of your Thunderbird package differs from the
        upstream version, override the internal `release` option.
      '';
      example = [
        "en-GB"
        "de"
      ];
    };

    policies = mkOption {
      type = types.attrsOf jsonFormat.type;
      default = { };
      description = ''
        Thunderbird enterprise policies. See the
        [list of policies](https://thunderbird.github.io/policy-templates/).
      '';
      example = {
        DisableTelemetry = true;
        ExtensionSettings = {
          "addoncompatibility@opto.one" = {
            install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/addon-compatibility-check/latest.xpi";
            installation_mode = "normal_installed";
          };
        };
      };
    };

    profileVersion = mkOption {
      internal = true;
      type = types.nullOr types.ints.unsigned;
      default = if isDarwin then null else 2;
      description = "profile version, set null for nix-darwin";
    };

    nativeMessagingHosts = mkOption {
      visible = true;
      type = types.listOf types.package;
      default = [ ];
      description = ''
        Additional packages containing native messaging hosts that should be
        made available to Thunderbird extensions.
      '';
    };

    profiles = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, name, ... }:
          {
            options = {
              name = mkOption {
                type = types.str;
                default = name;
                readOnly = true;
                description = "This profile's name.";
              };

              isDefault = mkOption {
                type = types.bool;
                default = false;
                example = true;
                description = ''
                  Whether this is a default profile. There must be exactly one
                  default profile.
                '';
              };

              feedAccounts = mkOption {
                type = types.attrsOf (
                  types.submodule (
                    { name, ... }:
                    {
                      options = {
                        name = mkOption {
                          type = types.str;
                          default = name;
                          readOnly = true;
                          description = "This feed account's name.";
                        };
                      };
                    }
                  )
                );
                default = { };
                description = ''
                  Attribute set of feed accounts. Feeds themselves have to be
                  managed through Thunderbird's settings. This option allows
                  feeds to coexist with declaratively managed email accounts.
                '';
              };

              settings = mkOption {
                type = thunderbirdJson;
                default = { };
                example = literalExpression ''
                  {
                    "mail.spellcheck.inline" = false;
                    "mailnews.database.global.views.global.columns" = {
                      selectCol = {
                        visible = false;
                        ordinal = 1;
                      };
                      threadCol = {
                        visible = true;
                        ordinal = 2;
                      };
                    };
                  }
                '';
                description = ''
                  Preferences to add to this profile's
                  {file}`user.js`.
                '';
              };

              accountsOrder = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = ''
                  Custom ordering of accounts and local folders in
                  Thunderbird's folder pane. The accounts are specified
                  by their name. For declarative accounts, it must be the name
                  of their attribute in `config.accounts.email.accounts` (or
                  `config.programs.thunderbird.profiles.<name>.feedAccounts`
                  for feed accounts). The local folders name can be found in
                  the `mail.accountmanager.accounts` Thunderbird preference,
                  for example with Settings > Config Editor ("account1" by
                  default). Enabled accounts and local folders that aren't
                  listed here appear in an arbitrary order after the ordered
                  accounts.
                '';
                example = ''
                  [
                    "my-awesome-account"
                    "private"
                    "work"
                    "rss"
                    /* Other accounts in arbitrary order */
                  ]
                '';
              };

              calendarAccountsOrder = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = ''
                  Custom ordering of calendar accounts. The accounts are specified
                  by their name. For declarative accounts, it must be the name
                  of their attribute in `config.accounts.calendar.accounts`.
                  Enabled accounts that aren't listed here appear in an arbitrary
                  order after the ordered accounts.
                '';
                example = ''
                  [
                    "my-awesome-account"
                    "private"
                    "work"
                    "holidays"
                    /* Other accounts in arbitrary order */
                  ]
                '';
              };

              withExternalGnupg = mkOption {
                type = types.bool;
                default = false;
                example = true;
                description = ''
                  Allow Thunderbird to use external GnuPG secret keys through
                  GPGME, as used by its documented smartcard and external-key
                  workflow.

                  This installs `gpgme` and sets
                  `mail.openpgp.allow_external_gnupg`. Public keys and key
                  acceptance settings still live in Thunderbird's internal
                  OpenPGP key manager.
                '';
              };

              userChrome = mkOption {
                type = types.lines;
                default = "";
                description = "Custom Thunderbird user chrome CSS.";
                example = ''
                  /* Hide tab bar in Thunderbird */
                  #tabs-toolbar {
                    visibility: collapse !important;
                  }
                '';
              };

              userContent = mkOption {
                type = types.lines;
                default = "";
                description = "Custom Thunderbird user content CSS.";
                example = ''
                  /* Hide scrollbar on Thunderbird pages */
                  *{scrollbar-width:none !important}
                '';
              };

              extraConfig = mkOption {
                type = types.lines;
                default = "";
                description = ''
                  Extra preferences to add to {file}`user.js`.
                '';
              };

              search = mkOption {
                type = types.submodule (
                  args:
                  import ../firefox/profiles/search.nix {
                    inherit (args) config;
                    inherit lib pkgs;
                    appName = "Thunderbird";
                    inherit (cfg) package;
                    modulePath = [
                      "programs"
                      "thunderbird"
                      "profiles"
                      name
                      "search"
                    ];
                    profilePath = name;
                  }
                );
                default = { };
                description = "Declarative search engine configuration.";
              };

              extensions = mkOption {
                type = types.listOf types.package;
                default = [ ];
                example = literalExpression ''
                  [
                    pkgs.some-thunderbird-extension
                  ]
                '';
                description = ''
                  List of ${name} add-on packages to install for this profile.

                  Note that it is necessary to manually enable extensions
                  inside ${name} after the first installation.

                  To automatically enable extensions add
                  `"extensions.autoDisableScopes" = 0;`
                  to
                  [{option}`${moduleName}.profiles.<profile>.settings`](#opt-${moduleName}.profiles._name_.settings)
                '';
              };
            };
          }
        )
      );
      description = "Attribute set of Thunderbird profiles.";
    };

    settings = mkOption {
      type = thunderbirdJson;
      default = { };
      example = literalExpression ''
        {
          "general.useragent.override" = "";
          "privacy.donottrackheader.enabled" = true;
        }
      '';
      description = ''
        Attribute set of Thunderbird preferences to be added to
        all profiles.
      '';
    };

    darwinSetupWarning = mkOption {
      type = types.bool;
      default = true;
      example = false;
      visible = false;
      readOnly = !isDarwin;
      description = ''
        Using programs.thunderbird.darwinSetupWarning is deprecated. The
        module is compatible with all Thunderbird installations.
      '';
    };
  };
}
