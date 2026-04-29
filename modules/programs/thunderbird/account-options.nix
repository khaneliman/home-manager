{ lib }:
let
  inherit (lib)
    literalExpression
    mkOption
    mkOptionDefault
    types
    ;
in
{
  accounts.email.accounts = mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, ... }:
        {
          config.thunderbird = {
            settings = lib.mkIf (config.flavor == "gmail.com" || config.flavor == "outlook.office365.com") (
              id:
              lib.optionalAttrs (config.smtp != null && config.smtp.authentication == null) {
                "mail.smtpserver.smtp_${id}.authMethod" = mkOptionDefault 10; # 10 = OAuth2
              }
              // lib.optionalAttrs (config.imap != null && config.imap.authentication == null) {
                "mail.server.server_${id}.authMethod" = mkOptionDefault 10; # 10 = OAuth2
              }
              // lib.optionalAttrs (config.flavor == "gmail.com") {
                "mail.server.server_${id}.is_gmail" = mkOptionDefault true; # handle labels, trash, etc
              }
            );
          };

          options.thunderbird = {
            enable = lib.mkEnableOption "the Thunderbird mail client for this account";

            profiles = mkOption {
              type = with types; listOf str;
              default = [ ];
              example = literalExpression ''
                [ "profile1" "profile2" ]
              '';
              description = ''
                List of Thunderbird profiles for which this account should be
                enabled. If this list is empty (the default), this account will
                be enabled for all declared profiles.
              '';
            };

            settings = mkOption {
              type =
                with types;
                functionTo (
                  attrsOf (oneOf [
                    bool
                    int
                    str
                  ])
                );
              default = _: { };
              defaultText = literalExpression "_: { }";
              example = literalExpression ''
                id: {
                  "mail.server.server_''${id}.check_new_mail" = false;
                };
              '';
              description = ''
                Extra settings to add to this Thunderbird account configuration.
                The {var}`id` given as argument is an automatically
                generated account identifier.
              '';
            };

            perIdentitySettings = mkOption {
              type =
                with types;
                functionTo (
                  attrsOf (oneOf [
                    bool
                    int
                    str
                  ])
                );
              default = _: { };
              defaultText = literalExpression "_: { }";
              example = literalExpression ''
                id: {
                  "mail.identity.id_''${id}.protectSubject" = false;
                  "mail.identity.id_''${id}.autoEncryptDrafts" = false;
                };
              '';
              description = ''
                Extra settings to add to each identity of this Thunderbird
                account configuration. The {var}`id` given as
                argument is an automatically generated identifier.
              '';
            };

            messageFilters = mkOption {
              type = types.listOf (
                types.submodule {
                  options = {
                    name = mkOption {
                      type = types.str;
                      description = "Name for the filter.";
                    };

                    enabled = mkOption {
                      type = types.bool;
                      default = true;
                      description = "Whether this filter is currently active.";
                    };

                    type = mkOption {
                      type = types.str;
                      description = ''
                        Thunderbird filter type bitmask written as the
                        `type="..."` field in `msgFilterRules.dat`.

                        Thunderbird does not publish a stable table for this
                        bitmask. To reuse an existing value, inspect the
                        account's `msgFilterRules.dat` file and copy the
                        `type="..."` field from a comparable filter.
                      '';
                    };

                    action = mkOption {
                      type = types.str;
                      description = "Action to perform on matched messages.";
                    };

                    actionValue = mkOption {
                      type = types.nullOr types.str;
                      default = null;
                      description = "Argument passed to the filter action, e.g. a folder path.";
                    };

                    condition = mkOption {
                      type = types.str;
                      description = "Condition to match messages against.";
                    };

                    extraConfig = mkOption {
                      type = types.nullOr types.str;
                      default = null;
                      description = "Extra settings to apply to the filter";
                    };

                    text = mkOption {
                      type = types.nullOr types.str;
                      default = null;
                      description = ''
                        The raw text of the filter.
                        Note that this will override all other options.
                      '';
                    };
                  };
                }
              );
              default = [ ];
              defaultText = literalExpression "[ ]";
              example = literalExpression ''
                [
                  {
                    name = "Mark as Read on Archive";
                    enabled = true;
                    type = "128";
                    action = "Mark read";
                    condition = "ALL";
                  }
                ]
              '';
              description = ''
                List of message filters to add to this Thunderbird account configuration.

                Home Manager writes these to Thunderbird's per-account
                `msgFilterRules.dat` file under the profile mail server
                directory, for example `ImapMail/<server>/msgFilterRules.dat`.

                Thunderbird does not publish a stable reference for all fields
                in this file. To migrate existing filters, inspect an existing
                `msgFilterRules.dat` file and translate each filter block into
                this option.
              '';
            };
          };
        }
      )
    );
  };

  accounts.calendar.accounts = mkOption {
    type = types.attrsOf (
      types.submodule {
        options.thunderbird = {
          enable = lib.mkEnableOption "the Thunderbird mail client for this account";

          profiles = mkOption {
            type = types.listOf types.str;
            default = [ ];
            example = literalExpression ''
              [ "profile1" "profile2" ]
            '';
            description = ''
              List of Thunderbird profiles for which this account should be
              enabled. If this list is empty (the default), this account will
              be enabled for all declared profiles.
            '';
          };

          readOnly = mkOption {
            type = types.bool;
            default = false;
            description = "Mark calendar as read only";
          };

          color = mkOption {
            type = types.str;
            default = "";
            example = "#dc8add";
            description = "Display color of the calendar in hex";
          };

          settings = mkOption {
            type =
              with types;
              functionTo (
                attrsOf (oneOf [
                  bool
                  int
                  str
                ])
              );
            default = _: { };
            defaultText = literalExpression "_: { }";
            example = literalExpression ''
              id: {
                "calendar.registry.''${id}.refreshInterval" = 5;

                # If "my-awesome-account" is the attribute name of an email account under
                # `config.accounts.email.accounts`, the below snippet links this calendar
                # account to "my-awesome-account".

                "calendar.registry.''${id}.imip.identity.key" =
                  "id_''${builtins.hashString "sha256" "my-awesome-account"}";
              };
            '';
            description = ''
              Extra settings to add to this Thunderbird calendar configuration.
              The {var}`id` given as argument is an automatically
              generated account identifier.
            '';
          };
        };
      }
    );
  };

  accounts.contact.accounts = mkOption {
    type = types.attrsOf (
      types.submodule {
        options.thunderbird = {
          enable = lib.mkEnableOption "the Thunderbird mail client for this account";

          profiles = mkOption {
            type = types.listOf types.str;
            default = [ ];
            example = literalExpression ''
              [ "profile1" "profile2" ]
            '';
            description = ''
              List of Thunderbird profiles for which this account should be
              enabled. If this list is empty (the default), this account will
              be enabled for all declared profiles.
            '';
          };

          token = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "secret_token";
            description = ''
              A token is generated when adding an address book manually to Thunderbird, this can be entered here.
            '';
          };
        };
      }
    );
  };
}
