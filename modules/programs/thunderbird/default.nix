{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    filter
    flatten
    length
    mapAttrsToList
    mkIf
    mkOptionDefault
    optionalString
    ;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  cfg = config.programs.thunderbird;

  moduleName = "programs.thunderbird";

  thunderbird = import ./helpers.nix {
    inherit
      config
      lib
      pkgs
      cfg
      isDarwin
      moduleName
      ;
  };

  inherit (thunderbird)
    addId
    enabledCalendarAccounts
    enabledCalendarAccountsWithId
    enabledContactAccounts
    enabledContactAccountsWithId
    enabledEmailAccounts
    enabledEmailAccountsWithId
    extensionPath
    getAccountsForProfile
    getId
    mkFilterListToIni
    mkUserJs
    profilesIni
    profilesWithId
    thunderbirdConfigPath
    thunderbirdProfilesPath
    toThunderbirdAccount
    toThunderbirdCalendar
    toThunderbirdContact
    toThunderbirdFeed
    unsupportedAuthMethodWarnings
    ;
in
{
  meta.maintainers = [
    lib.hm.maintainers.d-dervishi
    lib.maintainers.jkarlson
  ];

  options = lib.recursiveUpdate (import ./program-options.nix {
    inherit
      config
      lib
      pkgs
      isDarwin
      moduleName
      ;
  }) (import ./account-options.nix { inherit lib; });

  config = mkIf cfg.enable {
    assertions = [
      (
        let
          defaults = lib.catAttrs "name" (filter (a: a.isDefault) profilesWithId);
        in
        {
          assertion = cfg.profiles == { } || length defaults == 1;
          message =
            "Must have exactly one default Thunderbird profile but found "
            + toString (length defaults)
            + optionalString (length defaults > 1) (", namely " + concatStringsSep "," defaults);
        }
      )

      {
        assertion = cfg.policies == { } || cfg.package ? override;
        message = ''
          'programs.thunderbird.policies' requires 'programs.thunderbird.package'
          to be a package that supports overriding wrapper arguments.
        '';
      }

      (
        let
          profiles = lib.catAttrs "name" profilesWithId;
          selectedProfiles = lib.concatMap (a: a.thunderbird.profiles) (
            enabledEmailAccounts ++ enabledCalendarAccounts
          );
        in
        {
          assertion = (lib.intersectLists profiles selectedProfiles) == selectedProfiles;
          message =
            "Cannot enable an account for a non-declared profile. "
            + "The declared profiles are "
            + (concatStringsSep "," profiles)
            + ", but the used profiles are "
            + (concatStringsSep "," selectedProfiles);
        }
      )

      (
        let
          foundCalendars = filter (
            a: a.remote != null && a.remote.type == "google_calendar"
          ) enabledCalendarAccounts;
        in
        {
          assertion = length foundCalendars == 0;
          message =
            '''accounts.calendar.accounts.<name>.remote.type = "google_calendar";' is not directly supported by Thunderbird, ''
            + "but declared for these calendars: "
            + (concatStringsSep ", " (lib.catAttrs "name" foundCalendars))
            + "\n"
            + ''
              To use google calendars in Thunderbird choose 'type = "caldav"' instead.
              The 'url' will be "https://apidata.googleusercontent.com/caldav/v2/ID/events/", replace ID with the "Calendar ID".
              The ID can be found in the Google Calendar web app: Settings > Settings for my calendars > scroll to "Integrate calendar" > copy the "Calendar ID".
            '';
        }
      )

      (
        let
          foundContacts = filter (
            a: a.remote != null && a.remote.type == "google_contacts"
          ) enabledContactAccounts;
        in
        {
          assertion = length foundContacts == 0;
          message =
            '''accounts.contact.accounts.<name>.remote.type = "google_contacts";' is not directly supported by Thunderbird, ''
            + "but declared for these address books: "
            + (concatStringsSep ", " (lib.catAttrs "name" foundContacts))
            + "\n"
            + ''
              To use google address books in Thunderbird choose 'type = "caldav"' instead.
              The 'url' will be something like "https://www.googleapis.com/carddav/v1/principals/[YOUR-MAIL-ADDRESS]/lists/default/".
              To get the exact URL, add the address book to Thunderbird manually and copy the URL from the "Advanced Preferences" section.
            '';
        }
      )

      (
        let
          foundContacts = filter (a: a.remote != null && a.remote.type == "http") enabledContactAccounts;
        in
        {
          assertion = length foundContacts == 0;
          message =
            '''accounts.contact.accounts.<name>.remote.type = "http";' is not supported by Thunderbird, ''
            + "but declared for these address books: "
            + (concatStringsSep ", " (lib.catAttrs "name" foundContacts))
            + "\n"
            + ''
              Use a calendar of 'type = "caldav"' instead.
            '';
        }
      )
    ];

    warnings =
      lib.optionals (!cfg.darwinSetupWarning) [
        ''
          Using programs.thunderbird.darwinSetupWarning is deprecated and will be
          removed in the future. Thunderbird is now supported on Darwin.
        ''
      ]
      ++ flatten (map unsupportedAuthMethodWarnings enabledEmailAccounts);

    home.packages = [
      cfg.finalPackage
    ]
    ++ lib.optional (lib.any (p: p.withExternalGnupg) (attrValues cfg.profiles)) pkgs.gpgme;

    mozilla.thunderbirdNativeMessagingHosts = [
      cfg.finalPackage # package configured native messaging hosts (entire mail app actually)
    ]
    ++ cfg.nativeMessagingHosts; # user configured native messaging hosts

    home.file = lib.mkMerge (
      [
        {
          "${thunderbirdConfigPath}/profiles.ini" = mkIf (cfg.profiles != { }) {
            text = lib.generators.toINI { } profilesIni;
          };
        }
      ]
      ++ lib.flip mapAttrsToList cfg.profiles (
        name: profile: {
          "${thunderbirdProfilesPath}/${name}/chrome/userChrome.css" = mkIf (profile.userChrome != "") {
            text = profile.userChrome;
          };

          "${thunderbirdProfilesPath}/${name}/chrome/userContent.css" = mkIf (profile.userContent != "") {
            text = profile.userContent;
          };

          "${thunderbirdProfilesPath}/${name}/user.js" =
            let
              emailAccounts = getAccountsForProfile name enabledEmailAccountsWithId;
              calendarAccounts = getAccountsForProfile name enabledCalendarAccountsWithId;
              contactAccounts = getAccountsForProfile name enabledContactAccountsWithId;

              accountsSmtp = filter (a: a.smtp != null) emailAccounts;
              aliasesSmtp =
                let
                  getAliasesWithSmtp = a: filter (al: builtins.isAttrs al && al.smtp != null) a.aliases;
                  getAliasesWithId = a: map (al: al // { id = getId a al; }) (getAliasesWithSmtp a);
                in
                flatten (map getAliasesWithId emailAccounts);
              smtp = accountsSmtp ++ aliasesSmtp;

              ews = filter (a: a.ews != null) emailAccounts;

              feedAccounts = addId (attrValues profile.feedAccounts);

              # NOTE: `calendarAccounts` not added here as calendars are not part of the 'Mail' view
              accounts = emailAccounts ++ feedAccounts;

              orderedAccounts =
                let
                  accountNameToId = builtins.listToAttrs (
                    map (a: {
                      inherit (a) name;
                      value = "account_${a.id}";
                    }) accounts
                  );

                  accountsOrderIds = map (a: accountNameToId."${a}" or a) profile.accountsOrder;

                  # Append the default local folder name "account1".
                  # See https://github.com/nix-community/home-manager/issues/5031.
                  enabledAccountsIds = (lib.attrsets.mapAttrsToList (_name: value: value) accountNameToId) ++ [
                    "account1"
                  ];
                in
                lib.optionals (accounts != [ ]) (
                  accountsOrderIds ++ (lib.lists.subtractLists accountsOrderIds enabledAccountsIds)
                );

              orderedCalendarAccounts =
                let
                  accountNameToId = builtins.listToAttrs (
                    map (a: {
                      inherit (a) name;
                      value = "calendar_${a.id}";
                    }) calendarAccounts
                  );

                  accountsOrderIds = map (a: accountNameToId."${a}" or a) profile.calendarAccountsOrder;

                  enabledAccountsIds = lib.attrsets.mapAttrsToList (_name: value: value) accountNameToId;
                in
                lib.optionals (calendarAccounts != [ ]) (
                  accountsOrderIds ++ (lib.lists.subtractLists accountsOrderIds enabledAccountsIds)
                );
            in
            {
              text = mkUserJs (builtins.foldl' (a: b: a // b) { } (
                [
                  cfg.settings

                  (lib.optionalAttrs (length orderedAccounts != 0) {
                    "mail.accountmanager.accounts" = concatStringsSep "," orderedAccounts;
                  })

                  (lib.optionalAttrs (length orderedCalendarAccounts != 0) {
                    "calendar.list.sortOrder" = concatStringsSep " " orderedCalendarAccounts;
                  })

                  (lib.optionalAttrs (length smtp != 0 || length ews != 0) {
                    "mail.smtpservers" = concatStringsSep "," (
                      (map (a: "smtp_${a.id}") smtp) ++ (map (a: "ews_${a.id}") ews)
                    );
                  })

                  { "mail.openpgp.allow_external_gnupg" = profile.withExternalGnupg; }

                  profile.settings
                ]
                ++ (map (a: toThunderbirdAccount a profile) emailAccounts)
                ++ (map (calendar: toThunderbirdCalendar calendar profile) calendarAccounts)
                ++ (map (contact: toThunderbirdContact contact profile) contactAccounts)
                ++ (map (feed: toThunderbirdFeed feed profile) feedAccounts)
              )) profile.extraConfig;
            };

          "${thunderbirdProfilesPath}/${name}/search.json.mozlz4" = mkIf (profile.search.enable) {
            inherit (profile.search) enable force;
            source = profile.search.file;
          };

          "${thunderbirdProfilesPath}/${name}/extensions" = mkIf (profile.extensions != [ ]) {
            source =
              let
                extensionsEnvPkg = pkgs.buildEnv {
                  name = "hm-thunderbird-extensions";
                  paths = profile.extensions;
                };
              in
              "${extensionsEnvPkg}/share/mozilla/${extensionPath}";
            recursive = true;
            force = true;
          };
        }
      )
      ++ (mapAttrsToList (
        name: _profile:
        let
          emailAccountsWithFilters = filter (a: a.thunderbird.messageFilters != [ ]) (
            getAccountsForProfile name enabledEmailAccountsWithId
          );
        in
        builtins.listToAttrs (
          map (a: {
            name =
              "${thunderbirdProfilesPath}/${name}/"
              + (if a.ews != null then "Mail" else "ImapMail")
              + "/${a.id}/msgFilterRules.dat";
            value = {
              text = mkFilterListToIni a.thunderbird.messageFilters;
            };
          }) emailAccountsWithFilters
        )
      ) cfg.profiles)
    );

    programs.thunderbird = {
      finalPackage =
        if cfg.policies == { } then
          cfg.package
        else
          cfg.package.override (old: {
            extraPolicies = (old.extraPolicies or { }) // cfg.policies;
          });

      release = mkOptionDefault (
        builtins.head (lib.splitString "-" (cfg.package.version or (lib.getVersion cfg.package)))
      );

      policies = {
        RequestedLocales = lib.mkIf (cfg.languagePacks != [ ]) (concatStringsSep "," cfg.languagePacks);
        ExtensionSettings = lib.mkIf (cfg.languagePacks != [ ]) (
          lib.listToAttrs (
            map (
              lang:
              lib.nameValuePair "langpack-${lang}@thunderbird.mozilla.org" {
                installation_mode = "normal_installed";
                install_url = "https://releases.mozilla.org/pub/thunderbird/releases/${cfg.release}/linux-x86_64/xpi/${lang}.xpi";
              }
            ) cfg.languagePacks
          )
        );
      };
    };
  };
}
